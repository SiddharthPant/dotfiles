# Loaded by every zsh invocation. Keep this file fast and non-interactive.

export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/opt/make/libexec/gnubin:$HOME/.composer/vendor/bin:$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$HOME/Library/Application Support/Herd/bin:$HOME/.cargo/bin:$PATH:$HOME/.lmstudio/bin"

export FZF_DEFAULT_COMMAND="rg --files --ignore-vcs --hidden"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# pi: use FFF to override built-in find/grep tool names (requires pi restart)
export PI_FFF_MODE="override"
export FFF_FRECENCY_DB="$HOME/.cache/nvim/fff_frecency"
export FFF_HISTORY_DB="$HOME/.local/share/nvim/fff_history"

if [ -d "$HOME/Library/Application Support/Herd/config/php/83" ]; then
  export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"
fi

if [ -d "$HOME/Library/Application Support/Herd/config/php/84" ]; then
  export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
fi
