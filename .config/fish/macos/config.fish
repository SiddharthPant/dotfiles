# Environment shared with the macOS Zsh setup.
set -gx EDITOR vim
set -gx VISUAL $EDITOR
set -gx FZF_DEFAULT_COMMAND 'rg --files --ignore-vcs --hidden'

# Keep the effective macOS paths reproducible without relying on universal
# fish_user_paths state. fish_add_path ignores directories that do not exist.
fish_add_path --global \
    /opt/homebrew/bin \
    /opt/homebrew/sbin \
    /opt/homebrew/opt/make/libexec/gnubin \
    /usr/local/bin \
    $HOME/.local/bin \
    $HOME/.cargo/bin \
    "$HOME/Library/Application Support/Herd/bin" \
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" \
    $HOME/.rd/bin \
    /Users/Shared/DBngin/postgresql/17.0/bin \
    /Users/Shared/DBngin/mysql/8.4.2/bin \
    $HOME/.lmstudio/bin \
    /Library/Frameworks/Python.framework/Versions/3.12/bin

# This socket appears while the corresponding local MySQL service is running.
set -gx MYSQL_UNIX_PORT /tmp/mysql_3306.sock

if test -d "$HOME/Library/Application Support/Herd/config/php/84"
    set -gx HERD_PHP_84_INI_SCAN_DIR "$HOME/Library/Application Support/Herd/config/php/84/"
end

/Users/sid/.local/bin/mise activate fish | source

if status is-interactive
    set -g fish_greeting

    zoxide init fish | source

    fzf_configure_bindings --history=
    bind \cr history-pager

    abbr --add --global a 'php artisan'
    abbr --add --global chrome '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
end

set -Ux MISE_PIN 1
