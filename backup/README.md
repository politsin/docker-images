# S3 Dockup images

Build on `lp-close` from the repository root, after the PHP stack has finished:

```sh
RELEASE_ID=20261021 LOG_DIR=/opt/docker-images/report/build-20261021 \
  ./backup/build.sh 8.5 8.3 8.1
```

The script sorts branches descending, verifies the local PHP base, builds a
candidate, checks its PHP security fixes, console startup as `www-data`,
mydumper, AWS CLI and Composer platform requirements, then immediately pushes
both `synstd/s3-dockup:<branch>-build<release-id>` and `:<branch>`.
PHP 8.5 and 8.3 use `synstd/php`; PHP 8.1 uses `synstd/php-service`.

Reuse the same release ID and log directory to resume. Completion markers
are accepted only when both the published image and PHP base IDs still match.
A failed build or verification stops the queue before publishing that branch.

For a build-only HTTP proxy, export `BUILD_PROXY` and optionally
`BUILD_NO_PROXY`; these are Docker build arguments, not final image variables.
The proxy must be reachable through the host network. The PHP security gate
rejects an image if proxy variables leak into its runtime environment.

Select the runtime tag by PHP branch, rather than relying on `latest`.
Running application containers are not changed by this script.
