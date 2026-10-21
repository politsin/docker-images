#!/usr/bin/env python3
"""Install checksum-locked Launchpad core packages while PPA publication lags.

The PPA still supplies external extensions. Only already-installed core packages
from the specified successful vendor build are replaced. No unverified package
or package from another PHP branch/architecture is accepted.
"""
import concurrent.futures
import email.parser
import hashlib
import json
import pathlib
import re
import subprocess
import sys
import tempfile
import urllib.parse

branch = sys.argv[1]
lock_path = pathlib.Path('/usr/local/share/php-security/sources.json')
source = json.loads(lock_path.read_text()).get(branch)
if source is None:
    print('No vendor artifact override for PHP ' + branch)
    sys.exit(0)
installed_version = subprocess.check_output(
    ['dpkg-query', '-W', '-f=${Version}', 'php' + branch + '-cli'], text=True,
)
if subprocess.run(['dpkg', '--compare-versions', installed_version, 'ge', source['version']]).returncode == 0:
    print('APT core packages already meet vendor security source: ' + installed_version)
    sys.exit(0)


def download(url, path, expected_hash):
    if not url.startswith('https://launchpad.net/~ondrej/+archive/ubuntu/php/'):
        raise RuntimeError('Unexpected vendor artifact origin')
    subprocess.run([
        'curl', '-4', '--fail', '--show-error', '--location', '--retry', '5',
        '--proto', '=https', '--proto-redir', '=https',
        '--retry-all-errors', '--connect-timeout', '10', '--max-time', '180',
        '--continue-at', '-', '--output', str(path), url,
    ], check=True)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if digest != expected_hash:
        raise RuntimeError('SHA256 mismatch: ' + path.name)


with tempfile.TemporaryDirectory(prefix='php-security-') as temporary:
    work = pathlib.Path(temporary)
    changes_path = work / 'vendor.changes'
    download(source['changes_url'], changes_path, source['changes_sha256'])
    metadata = email.parser.Parser().parsestr(changes_path.read_text())
    if (metadata['Source'] != 'php' + branch
            or metadata['Version'] != source['version']
            or metadata['Distribution'] != 'noble'
            or 'amd64' not in metadata['Architecture'].split()):
        raise RuntimeError('Vendor build identity mismatch')
    selected = []
    for line in metadata['Checksums-Sha256'].splitlines():
        if not line.strip():
            continue
        digest, size, name = line.split()
        if not re.fullmatch(r'[a-zA-Z0-9_.+~-]+', name):
            raise RuntimeError('Invalid vendor artifact filename')
        if not name.endswith('_amd64.deb') or not name.startswith('php' + branch + '-'):
            continue
        package = name.split('_')[0]
        if package.endswith('-dbgsym'):
            continue
        installed = subprocess.run(
            ['dpkg-query', '-W', '-f=${db:Status-Status}', package],
            text=True, capture_output=True,
        )
        if installed.returncode == 0 and installed.stdout == 'installed':
            selected.append((package, name, digest, int(size)))
    if not selected or not any(package == 'php' + branch + '-cli' for package, *_ in selected):
        raise RuntimeError('No installed PHP CLI/core package set matched vendor build')

    def fetch(entry):
        package, name, digest, size = entry
        path = work / name
        url = source['changes_url'].rsplit('/', 1)[0] + '/' + urllib.parse.quote(name)
        download(url, path, digest)
        if path.stat().st_size != size:
            raise RuntimeError('Vendor artifact size mismatch: ' + name)
        print('VERIFIED ' + package + ' ' + digest, flush=True)
        return str(path)

    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        debs = list(pool.map(fetch, selected))
    subprocess.run(['apt-get', 'install', '-y', '--no-install-recommends'] + debs, check=True)
    for package, *_ in selected:
        version = subprocess.check_output(
            ['dpkg-query', '-W', '-f=${Version}', package], text=True,
        )
        if version != source['version']:
            raise RuntimeError('Installed version differs from locked vendor version: ' + package)
    evidence = lock_path.parent / (branch + '.changes')
    evidence.write_bytes(changes_path.read_bytes())
    print('VENDOR_CORE_SECURITY_PACKAGES_OK ' + branch + ' ' + source['version'])
