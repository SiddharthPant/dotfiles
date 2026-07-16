/bin/mise activate --shims fish | source
set -gx EDITOR nvim

if status is-interactive
# Commands to run in interactive sessions can go here
set -g fish_greeting
/bin/mise activate fish | source
herdr completion fish | source
fzf --fish | source
jj util completion fish | source
end

eval "$(zoxide init fish)"
fish_add_path $HOME/.local/bin
# set -gx PI_FFF_MODE override
set -gx FFF_ENABLE_ROOT_SCAN 1
set -gx FFF_FRECENCY_DB "$HOME/.cache/fff/frecency.db"
set -gx FFF_HISTORY_DB "$HOME/.cache/fff/history.db"
