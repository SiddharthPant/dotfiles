[[ ! -f ~/.zshrc.zwc || ~/.zshrc -nt ~/.zshrc.zwc ]] && zcompile ~/.zshrc 2>/dev/null

HISTSIZE=100000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory sharehistory incappendhistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

export FZF_DEFAULT_COMMAND='rg --files --ignore-vcs --hidden'
export EDITOR='nvim'
export VISUAL=$EDITOR   # For GUI-capable editors

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/sid/.docker/completions $fpath)

autoload -Uz compinit && compinit -C
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select  # Enable menu selection
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  # Add colors


# Herd injected NVM configuration
# export NVM_DIR="/Users/sid/Library/Application Support/Herd/config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
#
# [[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"


# Herd injected PHP binary.
export PATH="/Users/sid/Library/Application Support/Herd/bin:$PATH"

# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/sid/Library/Application Support/Herd/config/php/83/"

# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/sid/Library/Application Support/Herd/config/php/84/"

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

export PATH="$HOME/.composer/vendor/bin:$PATH"
# pnpm
export PNPM_HOME="/Users/sid/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Very slow adds 150ms to load times
# eval "$(uv generate-shell-completion zsh)"
# eval "$(uvx --generate-shell-completion zsh)"

export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

# Very slow add 500ms to load times
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/Users/sid/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/Users/sid/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/Users/sid/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/Users/sid/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

# export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
# eval "$(fnm env --use-on-cd --version-file-strategy recursive)"


# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(zoxide init --cmd cd zsh)"
# eval "$(starship init zsh)"

source "/opt/homebrew/opt/fzf/shell/completion.zsh"
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"


# ===== Aliases =====
alias timeout='gtimeout'
alias gst='git status'
alias gcmsg='git commit -m'
alias gcam='git commit --all -m'
alias ggp='git push'
alias ggl='git pull'
alias ga='git add'
alias glog='git log'
alias gco='git checkout'
alias gfa='git fetch --all'
alias gd='git diff'
alias gds='git diff --staged'
alias la='ls -lahFG'
alias drawio='/Applications/draw.io.app/Contents/MacOS/draw.io'
alias vim='nvim'
alias ls='eza --icons'

PS1='%F{blue}%~ %(?.%F{green}.%F{red})%#%f '
