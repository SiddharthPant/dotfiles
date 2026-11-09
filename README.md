# Dotfiles

Personal configuration for macOS and Windows, installed by [mise](https://mise.jdx.dev) tasks in `mise.toml`.

## Setup

```sh
mise trust && mise install   # pinned Go toolchain and linters
mise run build               # build and install setup-tool
setup-tool diff              # linux/macos preview what would change
.\setup-tool.exe diff        # same but for windows
mise run                     # install everything
```

Files are copied, not linked. Apps that edit their own settings, make copies drift: check with `setup-tool diff`, bring changes back with `setup-tool pull <tool>`.
