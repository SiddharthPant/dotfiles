set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
set -gx EDITOR "code -w"
set --global theme_display_date no
set -g theme_show_exit_status yes
set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore-vcs --hidden'

function set_virtual_env --on-event fish_prompt
    set --local pyenv_version_name (pyenv version-name)

    [ "$pyenv_version_name" = "$VIRTUAL_ENV" ]
    and return

    [ "$pyenv_version_name" = "system" ]
    and set --global --export VIRTUAL_ENV ""
    and return

    set --global --export VIRTUAL_ENV $pyenv_version_name
end
