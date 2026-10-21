# docker-php

https://hub.docker.com/r/synstd/php

base:

- php-fpm
- supervisor
- cron
- sshd

extra:

- phpcs
- nodeJS
- gulp

## Frontend checks

The image includes ESLint, @eslint/js, globals, Stylelint, the recommended
CSS/SCSS configs, stylelint-order, and editorconfig-checker. Gulp/Sass and the
legacy node-sass alias are retained. Dependencies are locked in
`config/frontend/package-lock.json` and installed with `npm ci`.

From a project under `/var/www`:

```sh
eslint path/to/js
stylelint 'path/to/styles/**/*.{css,scss}'
editorconfig-checker
```

Rules remain in the project's `eslint.config.mjs`, `stylelint.config.mjs`, and
`.editorconfig`. Nothing runs or fixes files automatically. Use `--fix` only
when you want files changed. Packages in `/var/node_modules` are visible to
projects below `/var` (including ESM imports); outside that tree install your
own dependencies. A project's installed packages take priority in resolution;
`npm run` also prefers its own CLI versions. Use project devDependencies and
a lockfile where exact project-specific versions are required.

## Building

From the repository root, `./build-php-stack.sh` builds PHP 8.5 down to 7.1,
in descending order. For a subset use `./build-php-stack.sh 8.5 8.3 7.4`.
Each PHP-service and PHP image is checked and pushed as soon as it is built.
The Ubuntu image is pulled once and pinned by digest for the whole run;
the common OS stage is reused. Do not use `NO_CACHE=1` unless intentionally
rebuilding every common layer. `RELEASE_ID` controls immutable build tags and
the log directory under `report/`. Only PHP 8.5 updates `latest`.

`grpc` and `dio` are enabled only in PHP 8.3, 8.4, and 8.5.
The security gate checks today's fixed releases (8.5.12 / 8.4.27 / 8.3.36 /
8.2.35); older branches must have evidence of vendor backports for both
CVE-2026-109618 and CVE-2026-109619 in the installed package changelog.
A package that fails this gate must not be published as an update.

When the PPA index still lags a successful vendor build, the release can use
`php-service/security-sources.json`. This locks a **noble amd64** Launchpad
build and the SHA256 of its `.changes` manifest. The installer verifies that
manifest and every downloaded core `.deb` against its SHA256, and updates only
PHP core packages already installed in the image. External extensions continue
to come from the signed PPA. The manifest remains in the image under
`/usr/local/share/php-security/` for audit. If apt already provides the locked
version or newer, no artifact override runs. Update these locks for future
security releases; do not substitute binaries built for a different Ubuntu
release or architecture.

If the builder needs a temporary transport, set `BUILD_PROXY` to a reachable
HTTP proxy. The scripts use host networking and predefined Docker proxy build
arguments; they never set proxy variables in the runtime image. `BUILD_NO_PROXY`
can override the default bypass list for Ubuntu mirrors and loopback addresses.
The publication check rejects an image containing runtime proxy variables.

After PHP completes, `RELEASE_ID=<same-id> ./backup/build.sh 8.5 8.3 8.1`
builds and pushes the requested dockup variants using the local checked bases.
Freshly built bases are never replaced with a remote tag by `--pull`.

Security reference: https://www.php.net/index.php#2026-10-21-1
