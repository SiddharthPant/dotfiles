# Dotfiles

Personal configuration for macOS and Windows, installed by [mise](https://mise.jdx.dev) tasks in `mise.toml`.

## Setup

```sh
mise trust && mise install   # pinned Rust toolchain
mise run build               # build and install setup-tool
setup-tool -ad      # preview what would change
mise run                     # install everything
```

Files are copied, not linked. Apps that edit their own settings, make copies drift: check with `-d`, bring changes back with `-p`.
