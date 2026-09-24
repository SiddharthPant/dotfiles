# Link helpers sourced by mise.toml Unix tasks. Sources are relative to the repo root.
root="$(pwd -P)"

link() {
  local src="$root/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    printf 'ok %s\n' "$dst"
  elif [ -L "$dst" ]; then
    rm "$dst"; ln -s "$src" "$dst"; printf 'relinked %s -> %s\n' "$dst" "$src"
  elif [ -e "$dst" ]; then
    printf 'error: %s exists and is not a symlink\n' "$dst" >&2; return 1
  else
    ln -s "$src" "$dst"; printf 'linked %s -> %s\n' "$dst" "$src"
  fi
}

# Seed mutable application state without linking it back into the repository
seed() {
  local src="$root/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    rm "$dst"; cp "$src" "$dst"; printf 'migrated %s to a local file\n' "$dst"
  elif [ -L "$dst" ]; then
    printf 'error: %s is an unmanaged symlink\n' "$dst" >&2; return 1
  elif [ -e "$dst" ]; then
    printf 'ok %s (local)\n' "$dst"
  else
    cp "$src" "$dst"; printf 'created %s from %s\n' "$dst" "$src"
  fi
}

unlink_managed() {
  local src="$root/$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    rm "$dst"; printf 'removed %s\n' "$dst"
  else
    printf 'skip %s\n' "$dst"
  fi
}

need() { command -v "$1" >/dev/null 2>&1 || { printf 'error: %s is not available in PATH\n' "$1" >&2; exit 1; }; }
