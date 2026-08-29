# Loaded by every zsh invocation. Keep this file fast and non-interactive.

export PATH="/opt/homebrew/opt/make/libexec/gnubin:$HOME/.composer/vendor/bin:$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$HOME/Library/Application Support/Herd/bin:$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$HOME/.cargo/bin:$HOME/.rd/bin:/Users/Shared/DBngin/postgresql/17.0/bin:/Users/Shared/DBngin/mysql/8.4.2/bin:$HOME/go/bin:/Library/Frameworks/Python.framework/Versions/3.12/bin:/Applications/Ghostty.app/Contents/MacOS:$PATH:$HOME/.lmstudio/bin"
eval "$("$HOME/.local/bin/mise" activate zsh --shims)"

export FZF_DEFAULT_COMMAND="rg --files --ignore-vcs --hidden"
export EDITOR="nvim"
export VISUAL="$EDITOR"
export MYSQL_UNIX_PORT="/tmp/mysql_3306.sock"

if [ -d "$HOME/Library/Application Support/Herd/config/php/84" ]; then
  export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
fi
