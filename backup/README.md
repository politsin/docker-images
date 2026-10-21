# S3 Dockup images

After building the PHP images, run from the repository root for each branch:

```sh
VERSION=8.5 BUILD=<next-number> ./backup/build.sh
```

Use the next numeric `BUILD` after the existing Docker Hub tags for that PHP
branch. The script verifies the PHP base, builds and checks the image, then
immediately pushes `synstd/s3-dockup:8.5.<build>` and `synstd/s3-dockup:8.5`.
Repeat for PHP 8.3 and 8.1. PHP 8.5/8.3 use `synstd/php`; 8.1 uses
`synstd/php-service`. An optional `BUILD_PROXY` applies only during the build.
