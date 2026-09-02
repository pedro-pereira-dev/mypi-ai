# mypi

Run the [Pi coding agent](https://github.com/earendil-works/pi) in a Linux OCI container with Podman. Node.js, npm, and Pi remain inside the image.

The launcher runs Pi as the invoking host user, mounts the selected project at `/workspace`, and persists Pi state in `$HOME/.config/mypi` by default.

## Requirements

Install [Podman](https://podman.io/docs/installation) and ensure `podman info` succeeds. On macOS, start the Podman machine first if necessary.

## Build

```sh
./oci/build
```

The default image is `mypi:local` and contains the latest Pi release. Select another image tag or Pi version with environment variables:

```sh
MYPI_IMAGE=mypi:test PI_VERSION=0.84.4 ./oci/build
```

| Variable | Default | Description |
| --- | --- | --- |
| `MYPI_IMAGE` | `mypi:local` | Image tag to build |
| `PI_VERSION` | latest | Pi version to install |

## Run

Start Pi with the current directory as its workspace:

```sh
./oci/mypi
```

Arguments are passed directly to Pi:

```sh
./oci/mypi --model anthropic/claude-sonnet-4-5
```

The launcher allocates a TTY when both its input and output are terminals. Redirected and automated commands run without a TTY.

| Variable | Default | Description |
| --- | --- | --- |
| `MYPI_IMAGE` | `mypi:local` | Image to run |
| `MYPI_PROJECT` | current directory | Host directory mounted at `/workspace` |
| `MYPI_CONFIG_DIR` | `$HOME/.config/mypi` | Host directory used for persistent Pi state |
| `MYPI_CPUS` | `4` | CPU limit |
| `MYPI_MEMORY` | `4g` | Memory limit |
| `MYPI_TMP_SIZE` | `512m` | `/tmp` size limit |

The state directory contains credentials and is set to mode `0700`. Override it with an absolute path:

```sh
MYPI_PROJECT="$HOME/projects/example" \
MYPI_CONFIG_DIR="$HOME/.config/mypi-example" \
./oci/mypi
```

## Security

The launcher:

- runs Pi with the invoking non-root host UID and GID;
- uses a read-only image root filesystem;
- drops all Linux capabilities and disables privilege escalation;
- mounts only the selected project and dedicated Pi state directory;
- provides a size-limited temporary `/tmp`;
- publishes no ports or host sockets;
- applies CPU and memory limits.

The project and state mounts are writable, and Pi retains outbound network access.

## Test

Build and verify the image, launcher, state permissions, and unsafe mount rejection:

```sh
./oci/test
```
