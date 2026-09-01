# mypi

Run the [Pi coding agent](https://github.com/earendil-works/pi) in a hardened Linux OCI image with Podman. Node.js, npm, and Pi remain inside the image and do not need to be installed directly on the host.

The image works on Linux and macOS. It is always a Linux image; Podman builds and runs the native `linux/amd64` or `linux/arm64` variant for the host.

## Requirements

Install [Podman](https://podman.io/docs/installation). On macOS, initialize and start its Linux virtual machine if necessary:

```sh
podman machine init
podman machine start
```

Confirm that Podman is accessible:

```sh
podman info
```

## Build

```sh
./oci/scripts/build
```

The default image is `mypi:local`, and it installs the latest available Pi version. Override the image tag or select a specific Pi version when needed:

```sh
MYPI_IMAGE=mypi:test PI_VERSION=0.84.4 ./oci/scripts/build
```

The image uses the floating `node:lts-bookworm-slim` base and installs the latest Pi release by default, so rebuilding can pick up newer Node LTS, Debian package revisions, and Pi releases. Set `PI_VERSION` when a reproducible Pi version is required.

## Run

Launch Pi with the current directory mounted at `/workspace`:

```sh
./oci/scripts/mypi
```

Arguments are passed directly to Pi:

```sh
./oci/scripts/mypi --model anthropic/claude-sonnet-4-5
```

Use a different project or image:

```sh
MYPI_PROJECT="$HOME/projects/example" MYPI_IMAGE=mypi:test ./oci/scripts/mypi
```

## Authentication And State

Run mypi and use Pi's `/login` command. Authentication, settings, sessions, and installed Pi packages persist at:

```text
$HOME/.config-mypi
```

This dedicated host directory is bind-mounted at `/home/pi/.pi/agent`. mypi does not implicitly mount `~/.pi/agent`, the host home directory, SSH agents, cloud configuration, or the Podman socket.

Override the state location with an absolute path:

```sh
MYPI_CONFIG_DIR=/absolute/private/path ./oci/scripts/mypi
```

The directory contains credentials. Keep it private and do not commit or broadly share it. Remove it while mypi is stopped to reset the containerized Pi installation.

Browser-based OAuth may require opening a displayed URL on the host and pasting a redirect URL or authorization code back into Pi.

## Settings

| Variable | Default | Purpose |
| --- | --- | --- |
| `MYPI_IMAGE` | `mypi:local` | Local image tag |
| `MYPI_PROJECT` | current directory | Host project mounted at `/workspace` |
| `MYPI_CONFIG_DIR` | `$HOME/.config-mypi` | Host-persisted Pi state |
| `MYPI_CPUS` | `4` | CPU limit |
| `MYPI_MEMORY` | `4g` | Memory limit |
| `MYPI_TMP_SIZE` | `512m` | Temporary filesystem limit |
| `MYPI_INTERACTIVE` | `1` | Set to `0` for automated non-TTY runs |
| `PI_VERSION` | latest available | Optional Pi version to install during the build |

## Security Boundary

The launcher:

- runs Pi with the invoking non-root host UID/GID;
- makes the image root filesystem read-only;
- drops all Linux capabilities;
- enables Podman's no-new-privileges policy;
- mounts only the selected project and dedicated Pi state directory;
- provides a size-limited temporary `/tmp`;
- publishes no ports and forwards no host sockets;
- applies CPU and memory limits.

The project and state mounts are writable by design. Pi has outbound network access because login, token refresh, model catalogs, and provider calls require it. This project does not enforce egress policy or defend against vulnerabilities in Podman, its VM, or the host kernel.

## Tests

Build and inspect a test image:

```sh
./oci/tests/test-build
```

Run the actual `mypi` launcher non-interactively and verify its host setup:

```sh
./oci/tests/test-mypi
```

## Troubleshooting

- **Podman is installed but unavailable:** run `podman machine start` on macOS. On Linux, verify rootless Podman and user namespaces with `podman info`.
- **Permission denied on Linux:** SELinux may require an appropriate container file label for the selected bind mounts. Do not recursively relabel broad paths such as `$HOME`.
- **No interactive display:** run from a terminal. For intentional non-TTY execution, set `MYPI_INTERACTIVE=0`.
- **Provider login cannot complete its browser callback:** open the URL on the host and use the provider's paste-back flow.
- **Corporate network failures:** configure only the required proxy values through Pi or Podman. mypi does not inherit arbitrary host credentials.

## Scope

The current project builds and runs Pi locally with Podman. Other OCI runtimes, registry publishing, image signing, SBOM publication, local model discovery, egress filtering, SSH forwarding, Podman socket access, Windows support, and Kubernetes deployment are out of scope.
