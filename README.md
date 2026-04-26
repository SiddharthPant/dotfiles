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
- `.config/nvim/` -> `~/.config/nvim`
- `.config/ghostty/` -> `~/.config/ghostty`
- `.config/kitty/` -> `~/.config/kitty`
- `.config/starship.toml` -> `~/.config/starship.toml`
- `zshrc/macos/.zshrc` -> `~/.zshrc` on macOS
- `zshrc/arch-i3/.zshrc` -> `~/.zshrc` on Arch Linux

## Layout

- `.tmux.conf`: tmux configuration
- `.gitconfig`: Git configuration
- `.config/nvim/`: Neovim configuration
- `.config/ghostty/`: Ghostty terminal configuration
- `.config/kitty/`: Kitty terminal configuration
- `.config/starship.toml`: Starship prompt configuration
- `zshrc/macos/.zshrc`: macOS Zsh configuration
- `zshrc/arch-i3/.zshrc`: Arch Linux Zsh configuration

## Neovim

Neovim is organized by responsibility instead of by plugin.

- `init.lua`: top-level load order for config modules
- `lua/config/options.lua`: editor options
- `lua/config/keymaps.lua`: general keymaps and toggles
- `lua/config/autocmds.lua`: autocommands
- `lua/config/completion.lua`: completion and Supermaven setup
- `lua/config/formatting.lua`: formatting tools
- `lua/config/linting.lua`: linting setup
- `lua/config/lsp.lua`: LSP and diagnostics behavior
- `lua/plugins/pack.lua`: plugin installation via `vim.pack`
- `lua/plugins/editor.lua`: editor/plugin runtime setup
- `lua/plugins/theme.lua`: colorscheme and theme config

See `.config/nvim/README.md` for the Neovim-specific layout.
See `AGENTS.md` for the repo-wide edit map for automated changes.
