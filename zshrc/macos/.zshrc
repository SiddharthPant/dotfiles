[[ ! -f ~/.zshrc.zwc || ~/.zshrc -nt ~/.zshrc.zwc ]] && zcompile ~/.zshrc 2>/dev/null

HISTSIZE=100000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory sharehistory incappendhistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/sid/.docker/completions $fpath)

autoload -Uz compinit && compinit -C
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select                    # Enable menu selection
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # Add colors

# Herd injected NVM configuration
# export NVM_DIR="/Users/sid/Library/Application Support/Herd/config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
#
# [[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"

source /opt/homebrew/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

source "/opt/homebrew/opt/fzf/shell/completion.zsh"
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# ===== Aliases =====
alias timeout='gtimeout'
alias la='ls -lahFG --color'
alias drawio='/Applications/draw.io.app/Contents/MacOS/draw.io'

PS1='%F{blue}%~ %(?.%F{green}.%F{red})%#%f '

# Terminal title: dir while idle, "dir — cmd" while a command runs
if [[ "$TERM" == *ghostty* || "$TERM_PROGRAM" == ghostty ]]; then
  _ghostty_title() { print -nP "\033]0;$1\007"; }
  precmd() { _ghostty_title "%~"; }
  preexec() { _ghostty_title "%~ — ${1[(w)1]}"; }
fi
