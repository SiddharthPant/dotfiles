# Load Antigen
source ~/.antigen.zsh
# Load Antigen configurations
antigen init ~/.antigenrc

export EDITOR=nvim
alias vim=nvim

export APP_ENV_PREFIX=XYZ-PROD

PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+="%{$fg_bold[white]%}%{$bg[red]%}$APP_ENV_PREFIX%{$reset_color%}"
PROMPT+=' %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)'
export PROMPT

export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8

alias aa="cd /srv/xyz/ && source venv/bin/activate"
alias aalog="/var/log/xyz/"
export PATH="$PATH:`yarn global bin`"
