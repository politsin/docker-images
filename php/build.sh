#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../build-lib.sh"
VERSION="${VERSION:-8.5}" BUILD="${BUILD:-10}" build_php_image php
