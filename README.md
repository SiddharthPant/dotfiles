# Dotfiles

Personal configuration files for daily development tools.

## Setup

The repo uses `Makefile` as the source of truth for what gets linked into `$HOME`.

- `make install`: auto-detect macOS, Arch Linux, or WSL and link managed dotfiles
- `make macos`: link macOS-specific Zsh and Mise configuration
- `make vscode-macos`: link macOS VS Code settings and install declared extensions
- `make vim`: link Vim configuration, install vim-plug, and install declared plugins
- `make arch`: link Arch Linux-specific Zsh configuration
- `make wsl`: link WSL-specific Fish and Mise configuration
- `make clean`: remove only repo-managed symlinks

## Managed Paths

These paths are currently managed by `Makefile`:

- `.tmux.conf` -> `~/.tmux.conf`
- `.gitconfig` -> `~/.gitconfig`
- `.zshenv` -> `~/.zshenv`
- `.vimrc` -> `~/.vimrc`
- `.config/nvim/` -> `~/.config/nvim`
- `.config/ghostty/` -> `~/.config/ghostty`
- `.config/kitty/` -> `~/.config/kitty`
- `.config/zed/` -> `~/.config/zed`
- `.config/emacs/` -> `~/.config/emacs`
- `.config/starship.toml` -> `~/.config/starship.toml`
- `.config/gh/config.yml` -> `~/.config/gh/config.yml`
- `.config/jj/config.toml` -> `~/.config/jj/config.toml`
- `.config/sqlfluff/` -> `~/.config/sqlfluff/`
- `.pi/agent/settings.json` -> `~/.pi/agent/settings.json`
- `.pi/web-search.json` -> `~/.pi/web-search.json`
- `.config/mise/macos/config.toml` -> `~/.config/mise/config.toml` on macOS
- `vscode/macos/settings.json` -> `~/Library/Application Support/Code/User/settings.json` on macOS
- `vscode/macos/keybindings.json` -> `~/Library/Application Support/Code/User/keybindings.json` on macOS
- `.config/mise/wsl/config.toml` -> `~/.config/mise/config.toml` on WSL
- `.config/fish/wsl/config.fish` -> `~/.config/fish/config.fish` on WSL
- `zshrc/macos/.zshrc` -> `~/.zshrc` on macOS
- `zshrc/arch-i3/.zshrc` -> `~/.zshrc` on Arch Linux

## Layout

- `.tmux.conf`: tmux configuration
- `.gitconfig`: Git configuration
- `.zshenv`: non-interactive-safe Zsh environment and PATH setup
- `.vimrc`: Vim 9.2 configuration managed with vim-plug
- `.config/nvim/`: Neovim configuration
- `.config/ghostty/`: Ghostty terminal configuration
- `.config/kitty/`: Kitty terminal configuration
- `.config/zed/`: Zed editor configuration
- `.config/emacs/`: Emacs configuration
- `.config/starship.toml`: Starship prompt configuration
- `.config/gh/config.yml`: GitHub CLI preferences (authentication stays outside the repo)
- `.config/jj/config.toml`: Jujutsu user configuration
- `.config/mise/{macos,wsl}/config.toml`: Platform-specific global Mise tools
- `vscode/macos/`: macOS VS Code settings, keybindings, and extension declarations
- `.config/fish/wsl/config.fish`: WSL Fish configuration
- `.config/sqlfluff/.sqlfluff`: sqlfluff configuration
- `.pi/agent/settings.json`: Pi preferences and package declarations
- `.pi/web-search.json`: Pi web-search plugin preferences
- `zshrc/macos/.zshrc`: macOS Zsh configuration
- `zshrc/arch-i3/.zshrc`: Arch Linux Zsh configuration

## Neovim

Neovim is a compact single-file config using native `vim.pack`.

- `init.lua`: options, keymaps, autocmds, plugins, LSP, completion, and snippets
- `nvim-pack-lock.json`: lockfile managed by `vim.pack`

See `.config/nvim/README.md` for plugin install/remove notes.
See `AGENTS.md` for the repo-wide edit map for automated changes.

## Vim

Vim 9.2 uses vim-plug for `vim-tmux-navigator`; run `make vim` to install both.
Use `:RepoDiff` or `<leader>gg` to open the current JJ or Git working-copy diff
in a disposable tab. Pass an optional directory, such as `:RepoDiff .config/nvim`,
to use the nearest repository containing that directory and limit the diff to
that path. Changed files start collapsed; use Vim's standard `z` commands to
reveal a complete file entry, and press `q` to close the tab.
