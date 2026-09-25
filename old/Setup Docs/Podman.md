# Podman Setup

This guide covers the two Podman environments used with these dotfiles:

- macOS, where Podman and Podman Desktop replace Docker Desktop
- Fedora Linux 44 in WSL 2, where Podman runs natively inside Linux

Both setups support Compose files and an optional `docker` command, but the
implementation differs by platform. On macOS, containers run inside a Podman
machine. On Fedora, Podman runs directly on the Linux kernel.

## macOS: Replace Docker Desktop with Podman

The macOS setup uses:

- the official Podman macOS installation under `/opt/podman`
- a libkrun-backed Podman machine
- Podman's Docker-compatible socket
- a small `/usr/local/bin/docker` wrapper
- Docker Compose as Podman's external Compose provider
- native Fish completions for both `podman` and `docker`

The final state documented here was verified on 2026-07-18.

### 1. Remove Docker Desktop

> [!WARNING]
> Uninstalling Docker Desktop and removing its data permanently deletes local
> containers, images, named volumes, settings, and registry configuration. Back
> up anything important first.

Quit Docker Desktop and run its own uninstaller:

```bash
/Applications/Docker.app/Contents/MacOS/uninstall
```

The uninstall on this Mac finished with the following macOS privacy error:

```text
Error: unlinkat /Users/sid/Library/Containers/com.docker.docker/.com.apple.containermanagerd.metadata.plist: operation not permitted
```

Running the same command with `sudo` does not help because Full Disk Access,
rather than Unix root permissions, protects that directory. Docker's remaining
components are still uninstalled successfully.

To remove the protected leftover:

1. Open **System Settings > Privacy & Security > Full Disk Access**.
2. Enable the terminal application in use.
3. Completely quit and reopen the terminal application.
4. Remove Docker's remaining user data:

```bash
rm -rf -- /Users/sid/Library/Containers/com.docker.docker
rm -rf -- "/Users/sid/Library/Group Containers/group.com.docker"
rm -rf -- /Users/sid/.docker
```

Remove the application itself:

```bash
rm -rf -- /Applications/Docker.app
```

This removes the application permanently instead of moving it to Trash.

Confirm that Docker Desktop is no longer running:

```bash
pgrep -fl 'Docker|com\.docker'
```

No output, with exit status `1`, means no process matched.

### 2. Remove Docker's Stale Socket

Docker Desktop left this stale symbolic link after its data directory was
removed:

```text
/var/run/docker.sock -> /Users/sid/.docker/run/docker.sock
```

Inspect the link before deleting it:

```bash
ls -la /var/run/docker.sock 2>/dev/null
```

When it still points to the removed Docker directory, remove only the link:

```bash
sudo rm -f -- /var/run/docker.sock
```

A macOS restart is unnecessary when no Docker process remains and the stale
socket is gone. Restart only if a Docker helper remains active or Podman cannot
claim `/var/run/docker.sock`.

### 3. Install Podman and Create the Machine

Install Podman Desktop from its official universal DMG and complete the
onboarding flow. Use the installer supplied through Podman Desktop rather than
mixing the DMG installation with Homebrew's Podman formula.

The installed Podman client is:

```text
/opt/podman/bin/podman
```

Podman Desktop creates and starts the default machine. The CLI equivalent on a
fresh installation is:

```bash
podman machine init --now
```

Verify the installation:

```bash
podman version
podman machine list
podman info
podman run --rm quay.io/podman/hello
```

The host-side configuration is stored at:

```text
~/.config/containers/containers.conf
```

The active machine provider is configured as:

```toml
[machine]
provider = "libkrun"
```

### 4. Enable Docker API Compatibility

In Podman Desktop, open **Settings > Preferences > Docker Compatibility** and
enable **Third-Party Docker Tool Compatibility**. This maps the conventional
Docker socket path to Podman's socket so tools such as Compose, Testcontainers,
IDEs, and build tools can use the Podman engine.

If Podman Desktop reports that compatibility is not configured, install the
helper and restart the Podman machine:

```bash
sudo podman-mac-helper install
podman machine stop
podman machine start
```

Verify the resulting link:

```bash
ls -la /var/run/docker.sock
```

It should point to:

```text
/Users/sid/.local/share/containers/podman/machine/podman.sock
```

### 5. Provide a `docker` Command

Fedora provides `podman-docker`, but macOS has no equivalent package. Install a
small executable wrapper instead:

```bash
printf '#!/bin/sh\nexec podman "$@"\n' \
  | sudo tee /usr/local/bin/docker >/dev/null
sudo chmod +x /usr/local/bin/docker
```

The wrapper contains:

```sh
#!/bin/sh
exec podman "$@"
```

This maps familiar commands directly to Podman:

```text
docker ps          -> podman ps
docker run ...     -> podman run ...
docker compose ... -> podman compose ...
```

An executable is preferable to a Fish alias here because scripts, Makefiles,
and other applications can also discover it through `PATH`.

Verify the wrapper:

```bash
command -v docker
docker --version
docker info
```

### 6. Configure Compose

During Podman Desktop onboarding, install the Compose CLI. It places the
external provider at:

```text
/usr/local/bin/docker-compose
```

Podman intentionally delegates Compose operations to an external provider. The
complete execution path is:

```text
/usr/local/bin/docker
  -> podman compose
  -> /usr/local/bin/docker-compose
  -> /var/run/docker.sock
  -> Podman machine
```

Verify Compose and the services in a project:

```bash
docker compose version
docker compose config --services
```

Start a service and wait until it is running or healthy:

```bash
docker compose up -d --wait db
docker compose ps db
```

### 7. Disable the External Provider Banner

By default, `podman compose` prints an informational message each time it
delegates to Compose:

```text
>>>> Executing external compose provider "/usr/local/bin/docker-compose". Please see podman-compose(1) for how to disable this message. <<<<
```

Disable the banner system-wide with an administrator-level configuration
drop-in:

```bash
sudo install -d -m 755 /etc/containers/containers.conf.d

printf '%s\n' \
  '[engine]' \
  'compose_warning_logs = false' \
  | sudo tee /etc/containers/containers.conf.d/99-compose.conf >/dev/null

sudo chmod 644 /etc/containers/containers.conf.d/99-compose.conf
```

The resulting file is:

```toml
[engine]
compose_warning_logs = false
```

The setting takes effect immediately. It does not require a new shell, a Podman
machine restart, or a macOS restart.

Verify it:

```bash
docker compose version
```

To restore the banner:

```bash
sudo rm -f -- /etc/containers/containers.conf.d/99-compose.conf
```

This is a system-wide default. A user's `containers.conf` or environment can
still override it.

### 8. Enable Fish Completions

Generate Podman's native Fish completion file:

```fish
mkdir -p ~/.config/fish/completions
podman completion -f ~/.config/fish/completions/podman.fish fish
```

Make the `docker` wrapper inherit the same completions:

```fish
printf '%s\n' \
    'complete -c docker --erase' \
    'complete -c docker --wraps podman' \
    > ~/.config/fish/completions/docker.fish
```

Load both files in the current shell:

```fish
source ~/.config/fish/completions/podman.fish
source ~/.config/fish/completions/docker.fish
```

Future Fish sessions load them automatically. Test by pressing Tab after:

```text
podman
docker
docker compose
```

Regenerate Podman's completion file after major Podman upgrades:

```fish
podman completion -f ~/.config/fish/completions/podman.fish fish
```

### 9. Verify the Final macOS Setup

Run the complete verification sequence:

```bash
podman machine list
podman version
podman info
docker --version
docker compose version
docker run --rm quay.io/podman/hello
ls -la /var/run/docker.sock
```

Verified state on 2026-07-18:

```text
Podman client:             5.8.3
Podman machine server:     5.8.5
Compose provider:          v5.3.1
Podman machine:            podman-machine-default
Machine provider:          libkrun
Machine state:             running
Docker-compatible socket:  /var/run/docker.sock -> Podman socket
```

Docker Desktop and its user data were confirmed absent:

```text
/Applications/Docker.app
/Users/sid/Library/Containers/com.docker.docker
/Users/sid/Library/Group Containers/group.com.docker
/Users/sid/.docker
```

The active macOS configuration consists of:

```text
/opt/podman/bin/podman
/usr/local/bin/docker
/usr/local/bin/docker-compose
~/.config/containers/containers.conf
~/.config/fish/completions/podman.fish
~/.config/fish/completions/docker.fish
/etc/containers/containers.conf.d/99-compose.conf
~/.local/share/containers/podman/machine/podman.sock
```

## Fedora Linux 44 in WSL 2

The Fedora setup runs Podman directly inside WSL 2. It uses Fedora packages for
Podman, Compose, and optional Docker CLI compatibility.

### 1. Confirm WSL 2

Run in Windows PowerShell:

```powershell
wsl --list --verbose
```

Ensure the Fedora distribution shows WSL version `2`. If necessary:

```powershell
wsl --set-version FedoraLinux-44 2
```

Replace `FedoraLinux-44` with the exact distribution name reported by WSL, then
update WSL:

```powershell
wsl --update
```

### 2. Install Podman and Compose

Inside Fedora, update the system:

```bash
sudo dnf upgrade --refresh -y
```

Install Podman and the Podman-native Compose implementation:

```bash
sudo dnf install -y podman podman-compose
```

Optionally install Fedora's `docker` compatibility wrapper:

```bash
sudo dnf install -y podman-docker
```

The package roles are distinct:

- `podman` provides the container engine and CLI.
- `podman-compose` runs Compose files with Podman.
- `podman-docker` provides a `docker` command that executes Podman.

Verify the installation:

```bash
podman --version
podman-compose --version
podman info
```

### 3. Use Docker Hub for Unqualified Images

Create a system-wide registry configuration drop-in:

```bash
sudo mkdir -p /etc/containers/registries.conf.d

sudo tee /etc/containers/registries.conf.d/10-docker-hub.conf >/dev/null <<'EOF'
unqualified-search-registries = ["docker.io"]
EOF
```

This makes names such as `nginx`, `postgres:17`, and `redis:latest` resolve
through Docker Hub.

Verify the effective search registry:

```bash
podman info --format '{{json .Registries.Search}}'
```

Expected output:

```json
["docker.io"]
```

Test an unqualified pull:

```bash
podman pull nginx
```

The resulting image name should be `docker.io/library/nginx`.

### 4. Disable the External Provider Banner

Create a system-wide Podman configuration drop-in:

```bash
sudo mkdir -p /etc/containers/containers.conf.d

sudo tee /etc/containers/containers.conf.d/10-compose.conf >/dev/null <<'EOF'
[engine]
compose_warning_logs = false
EOF
```

Verify that Compose runs without the provider message:

```bash
podman compose version
podman compose ps
```

### 5. Test the Fedora Setup

Run a basic container:

```bash
podman run --rm docker.io/library/hello-world
```

Test the Docker Hub search configuration:

```bash
podman run --rm alpine echo "Podman is working"
```

When `podman-docker` is installed, test its wrapper:

```bash
docker run --rm alpine echo "Docker compatibility is working"
```

### 6. Optionally Enable systemd in WSL

Systemd is unnecessary for ordinary Podman commands. Enable it when using
Quadlet, system services, socket activation, or automatically managed
containers.

Create `/etc/wsl.conf`:

```bash
sudo tee /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true
EOF
```

Exit Fedora:

```bash
exit
```

Restart WSL from PowerShell:

```powershell
wsl --shutdown
```

Open Fedora again and verify:

```bash
systemctl is-system-running
```

An output of `running` or `degraded` generally means systemd is active.

### 7. Verify the Final Fedora Setup

```bash
podman --version
podman info
podman compose version
podman info --format '{{json .Registries.Search}}'
podman run --rm alpine echo "Podman setup complete"
```

The Fedora setup creates these system-wide files:

```text
/etc/containers/registries.conf.d/10-docker-hub.conf
/etc/containers/containers.conf.d/10-compose.conf
/etc/wsl.conf  # only when systemd is enabled
```

## Configuration Reference

| Purpose | macOS | Fedora WSL |
| --- | --- | --- |
| Podman client | `/opt/podman/bin/podman` | `/usr/bin/podman` |
| Container runtime | Podman machine | Native WSL 2 Linux kernel |
| `docker` command | `/usr/local/bin/docker` wrapper | `podman-docker` package |
| Compose provider | `/usr/local/bin/docker-compose` | `podman-compose` package |
| User configuration | `~/.config/containers/containers.conf` | `~/.config/containers/containers.conf` |
| Admin configuration | `/etc/containers/containers.conf.d/` | `/etc/containers/containers.conf.d/` |
| Docker API socket | `/var/run/docker.sock` mapped to Podman | Podman socket when enabled |
| Fish completions | `~/.config/fish/completions/` | Package-provided or generated |

## References

- [Docker Desktop uninstall documentation](https://docs.docker.com/desktop/uninstall/)
- [Podman installation documentation](https://podman.io/docs/installation)
- [Podman Desktop installation on macOS](https://podman-desktop.io/docs/installation/macos-install)
- [Podman Docker compatibility](https://podman-desktop.io/docs/migrating-from-docker/managing-docker-compatibility)
- [Podman Compose documentation](https://docs.podman.io/en/stable/markdown/podman-compose.1.html)
- [Podman completion documentation](https://docs.podman.io/en/stable/markdown/podman-completion.1.html)
- [Containers configuration loading rules](https://www.mankier.com/5/containers-config)
