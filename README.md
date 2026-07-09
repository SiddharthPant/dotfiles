# Dotfiles

Personal configuration files for daily development tools.

## Setup

The repo uses `Makefile` as the source of truth for what gets linked into `$HOME`.

- `make install`: auto-detect platform and link managed dotfiles
- `make macos`: link macOS-specific shell config
- `make arch`: link Arch Linux-specific shell config
- `make clean`: remove only repo-managed symlinks

## Managed Paths

These paths are currently managed by `Makefile`:

- `.tmux.conf` -> `~/.tmux.conf`
- `.gitconfig` -> `~/.gitconfig`
- `.zshenv` -> `~/.zshenv`
- `.config/nvim/` -> `~/.config/nvim`
- `.config/ghostty/` -> `~/.config/ghostty`
- `.config/kitty/` -> `~/.config/kitty`
- `.config/zed/` -> `~/.config/zed`
- `.config/emacs/` -> `~/.config/emacs`
- `.config/starship.toml` -> `~/.config/starship.toml`
- `.config/mise/config.toml` -> `~/.config/mise/config.toml`
- `.config/sqlfluff/.sqlfluff` -> `~/.config/sqlfluff/.sqlfluff`
- `zshrc/macos/.zshrc` -> `~/.zshrc` on macOS
- `zshrc/arch-i3/.zshrc` -> `~/.zshrc` on Arch Linux

## Layout

- `.tmux.conf`: tmux configuration
- `.gitconfig`: Git configuration
- `.zshenv`: non-interactive-safe Zsh environment and PATH setup
- `.config/nvim/`: Neovim configuration
- `.config/ghostty/`: Ghostty terminal configuration
- `.config/kitty/`: Kitty terminal configuration
- `.config/zed/`: Zed editor configuration
- `.config/emacs/`: Emacs configuration
- `.config/starship.toml`: Starship prompt configuration
- `.config/mise/config.toml`: Global mise tools
- `.config/sqlfluff/.sqlfluff`: sqlfluff configuration
- `zshrc/macos/.zshrc`: macOS Zsh configuration
- `zshrc/arch-i3/.zshrc`: Arch Linux Zsh configuration

## Neovim

Neovim is a compact single-file config using native `vim.pack`.

- `init.lua`: options, keymaps, autocmds, plugins, LSP, completion, and snippets
- `nvim-pack-lock.json`: lockfile managed by `vim.pack`

See `.config/nvim/README.md` for plugin install/remove notes.
See `AGENTS.md` for the repo-wide edit map for automated changes.
