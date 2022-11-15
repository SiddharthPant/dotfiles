# Load Antigen
source ~/.antigen.zsh
# Load Antigen configurations
antigen init ~/.antigenrc

alias vim=nvim
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export EDITOR="nvim"
#
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
# PROMPT+=' %{$fg[cyan]%}%3~%{$reset_color%} $(git_prompt_info)'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/sid/mambaforge/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/sid/mambaforge/etc/profile.d/conda.sh" ]; then
        . "/home/sid/mambaforge/etc/profile.d/conda.sh"
    else
        export PATH="/home/sid/mambaforge/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/home/sid/mambaforge/etc/profile.d/mamba.sh" ]; then
    . "/home/sid/mambaforge/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

