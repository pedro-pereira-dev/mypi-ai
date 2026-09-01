# mypi OCI image

This directory builds and runs the [Pi coding agent](https://github.com/earendil-works/pi) in a Linux OCI container with Podman. The container runs as the host user, mounts the selected project at `/workspace`, and persists Pi state in `$HOME/.config-mypi` by default.

## Requirements

Install [Podman](https://podman.io/docs/installation) and ensure `podman info` succeeds.

## Build

Build the image with the latest Pi release:

```sh
./oci/scripts/build
```

Build a particular Pi version or use another image tag:

```sh
PI_VERSION=0.84.4 MYPI_IMAGE=mypi:test ./oci/scripts/build
```

| Variable | Default | Description |
| --- | --- | --- |
| `PI_VERSION` | latest | Pi version to install |
| `MYPI_IMAGE` | `mypi:local` | Image tag to build |

## Run

Start Pi with the current directory as its workspace:

```sh
./oci/scripts/mypi
```

Arguments after the script name are passed to Pi:

```sh
./oci/scripts/mypi --model anthropic/claude-sonnet-4-5
```

| Variable | Default | Description |
| --- | --- | --- |
| `MYPI_IMAGE` | `mypi:local` | Image to run |
| `MYPI_PROJECT` | current directory | Host directory mounted at `/workspace` |
| `MYPI_CONFIG_DIR` | `$HOME/.config-mypi` | Host directory used for persistent Pi state |
| `MYPI_CPUS` | `4` | CPU limit |
| `MYPI_MEMORY` | `4g` | Memory limit |
| `MYPI_TMP_SIZE` | `512m` | `/tmp` size limit |
| `MYPI_INTERACTIVE` | `1` | Set to `0` to run without a TTY |

Example with a different project and configuration directory:

```sh
MYPI_PROJECT="$HOME/projects/example" \
MYPI_CONFIG_DIR="$HOME/.config-mypi" \
./oci/scripts/mypi
```
