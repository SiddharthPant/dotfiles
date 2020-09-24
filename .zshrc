# Load Antigen
source ~/.antigen.zsh
# Load Antigen configurations
antigen init ~/.antigenrc

alias vim=nvim
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export EDITOR="nvim"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/sid/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/sid/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/sid/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/sid/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
