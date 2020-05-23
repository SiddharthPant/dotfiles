# Make VS Code default Editor for apps like git
set --global --export EDITOR "code -w"

# Configure FZF to use ripgrep for file search
set --global --export FZF_DEFAULT_COMMAND "rg --files --no-ignore-vcs --hidden"


set --global theme_display_date no
set --global theme_show_exit_status yes

# Disable pyenv prompt setting to avoid warning message
set --global --export VIRTUAL_ENV_DISABLE_PROMPT 1

function set_virtual_env --on-event fish_prompt --description "For updating pyenv env name in prompt"
    # This function works even when pyenv env is set using the local file

    set --local pyenv_version_name (pyenv version-name)

    # Check if env is already set. If yes we don't need to do anything
    [ "$pyenv_version_name" = "$VIRTUAL_ENV" ]
    and return

    # Remove env from prompt if default system python is set
    [ "$pyenv_version_name" = "system" ]
    and set --global --export VIRTUAL_ENV ""
    and return

    set --global --export VIRTUAL_ENV $pyenv_version_name
end
