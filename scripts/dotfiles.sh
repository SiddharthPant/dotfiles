# Helpers sourced by mise.toml Unix tasks.
need() { command -v "$1" >/dev/null 2>&1 || { printf 'error: %s is not available in PATH\n' "$1" >&2; exit 1; }; }
