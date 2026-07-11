# Podman Setup on Fedora Linux 44 in WSL 2

This guide installs Podman, enables Compose support, configures Docker Hub as the default registry, and disables the external Compose provider warning system-wide.

## 1. Confirm WSL 2

Run in Windows PowerShell:

```powershell
wsl --list --verbose
```

Ensure the Fedora distribution shows WSL version `2`.

If necessary:

```powershell
wsl --set-version FedoraLinux-44 2
```

Replace `FedoraLinux-44` with the exact distribution name shown by:

```powershell
wsl --list --verbose
```

Update WSL:

```powershell
wsl --update
```

## 2. Update Fedora

Run inside Fedora:

```bash
sudo dnf upgrade --refresh -y
```

## 3. Install Podman and Compose

```bash
sudo dnf install -y podman podman-compose
```

Optional Docker CLI compatibility:

```bash
sudo dnf install -y podman-docker
```

Verify the installation:

```bash
podman --version
podman-compose --version
podman info
```

## 4. Set Docker Hub as the Default Registry

Create a system-wide registry configuration drop-in:

```bash
sudo mkdir -p /etc/containers/registries.conf.d
```

```bash
sudo tee /etc/containers/registries.conf.d/10-docker-hub.conf >/dev/null <<'EOF'
unqualified-search-registries = ["docker.io"]
EOF
```

This makes unqualified images such as:

```text
nginx
postgres:17
redis:latest
```

resolve through Docker Hub.

Verify the effective configuration:

```bash
podman info --format '{{json .Registries.Search}}'
```

Expected output:

```json
["docker.io"]
```

Test it:

```bash
podman pull nginx
```

The downloaded image should appear as:

```text
docker.io/library/nginx
```

## 5. Disable the External Compose Provider Warning

`podman compose` delegates Compose commands to an external provider such as `/usr/bin/podman-compose` or `/usr/sbin/podman-compose`.

To suppress the informational warning system-wide, create a Podman configuration drop-in:

```bash
sudo mkdir -p /etc/containers/containers.conf.d
```

```bash
sudo tee /etc/containers/containers.conf.d/10-compose.conf >/dev/null <<'EOF'
[engine]
compose_warning_logs = false
EOF
```

Verify:

```bash
podman compose version
podman compose ps
```

The following warning should no longer appear:

```text
Executing external compose provider "/usr/sbin/podman-compose"
```

## 6. Test Podman

Run a basic container:

```bash
podman run --rm docker.io/library/hello-world
```

Test an unqualified image name:

```bash
podman run --rm alpine echo "Podman is working"
```

Test Docker CLI compatibility, when `podman-docker` was installed:

```bash
docker run --rm alpine echo "Docker compatibility is working"
```

## 7. Optional: Enable systemd in WSL

Systemd is not required for ordinary Podman commands. It is useful for Quadlet, system services, socket activation, and automatically managed containers.

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

## 8. Final Verification

```bash
podman --version
podman info
podman compose version
podman info --format '{{json .Registries.Search}}'
podman run --rm alpine echo "Setup complete"
```

## Configuration Files Created

The setup creates these system-wide files:

```text
/etc/containers/registries.conf.d/10-docker-hub.conf
/etc/containers/containers.conf.d/10-compose.conf
/etc/wsl.conf
```

Display them with:

```bash
sudo cat /etc/containers/registries.conf.d/10-docker-hub.conf
sudo cat /etc/containers/containers.conf.d/10-compose.conf
sudo cat /etc/wsl.conf
```

## Complete Installation Commands

```bash
sudo dnf upgrade --refresh -y

sudo dnf install -y \
  podman \
  podman-compose \
  podman-docker

sudo mkdir -p \
  /etc/containers/registries.conf.d \
  /etc/containers/containers.conf.d

sudo tee /etc/containers/registries.conf.d/10-docker-hub.conf >/dev/null <<'EOF'
unqualified-search-registries = ["docker.io"]
EOF

sudo tee /etc/containers/containers.conf.d/10-compose.conf >/dev/null <<'EOF'
[engine]
compose_warning_logs = false
EOF

podman info --format '{{json .Registries.Search}}'
podman compose version
podman run --rm alpine echo "Podman setup complete"
```

