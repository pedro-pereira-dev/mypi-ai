#!/bin/sh

set -eu

die() {
    printf '%s\n' "mypi: $*" >&2
    exit 1
}

require_podman() {
    command -v podman >/dev/null 2>&1 || die "Podman is not installed"
    podman info >/dev/null 2>&1 || die "Podman is not running or is not accessible"
}

absolute_dir() {
    [ -d "$1" ] || die "directory does not exist: $1"
    (CDPATH= cd -- "$1" && pwd -P)
}
