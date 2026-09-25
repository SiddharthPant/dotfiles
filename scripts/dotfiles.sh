# Helpers sourced by mise.toml Unix tasks. Paths are relative to the repo root.
root="$(pwd -P)"

# Remove a symlink left by the old link-based install, only if it points at this repo path
unlink_managed() {
  local src="$root/$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    rm "$dst"; printf 'removed %s\n' "$dst"
  else
    printf 'skip %s\n' "$dst"
  fi
}

need() { command -v "$1" >/dev/null 2>&1 || { printf 'error: %s is not available in PATH\n' "$1" >&2; exit 1; }; }
