# AGENTS.md

This repository contains personal dotfiles. `Makefile` is the source of truth for links into `$HOME`; inspect it before changing setup or installation behavior. Shell configuration lives in `.zshenv` and `zshrc/{macos,arch-i3}/`, terminal configuration in `.tmux.conf` and `.config/{ghostty,kitty}/`, editor configuration in `.config/{nvim,zed,emacs}/`, and tool configuration in `.gitconfig`, `.config/starship.toml`, `.config/mise/config.toml`, and `.config/sqlfluff/.sqlfluff`.

Neovim is the main active configuration. Keep behavior in `.config/nvim/init.lua`; Askama snippets belong in `.config/nvim/lua/snippets/htmldjango.lua`, and `.config/nvim/nvim-pack-lock.json` is managed by `vim.pack`. See `.config/nvim/README.md` for current usage and maintenance notes.

Make the smallest correct change and edit the existing responsible file rather than creating new modules. Keep related plugin setup and mappings together, preserve the marker-fold layout, use buffer-local mappings when appropriate, and prefer `vim.notify` for messages. Do not add leader mappings for commands that are already easy to invoke. For Neovim changes, verify with `nvim --headless -i NONE '+qa'`.

Commit messages must be a single-line subject with no co-author trailers.
