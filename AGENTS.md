# AGENTS.md

This repo contains personal dotfiles. The main actively used app config here is Neovim under `.config/nvim`.

## Managed By Makefile

`Makefile` is the source of truth for repo-managed links into `$HOME`.

Common links:

- `.tmux.conf` -> `~/.tmux.conf`
- `.config/nvim/` -> `~/.config/nvim`
- `.config/ghostty/` -> `~/.config/ghostty`
- `.config/kitty/` -> `~/.config/kitty`
- `.config/starship.toml` -> `~/.config/starship.toml`

Platform-specific `~/.zshrc` links:

- `zshrc/macos/.zshrc` on macOS
- `zshrc/arch-i3/.zshrc` on Arch Linux

If a task touches setup or installation behavior, inspect `Makefile` first.

## Scope

- Make the smallest correct change.
- Prefer editing the existing file responsible for the behavior instead of creating new modules.
- For Neovim changes, keep plugin declaration changes in `lua/plugins/pack.lua` and runtime/config changes in the matching `lua/config/*.lua` or `lua/plugins/*.lua` file.

## Repo Layout

- `.tmux.conf`: tmux configuration
- `.config/nvim/`: Neovim configuration
- `.config/ghostty/`: Ghostty terminal configuration
- `.config/kitty/`: Kitty terminal configuration
- `.config/starship.toml`: Starship prompt configuration
- `zshrc/macos/.zshrc`: macOS shell configuration
- `zshrc/arch-i3/.zshrc`: Arch Linux shell configuration

## Neovim Structure

For the Neovim-specific README, see `.config/nvim/README.md`.

Top-level entry:

- `.config/nvim/init.lua`: loads config in this order:
  - `config.options`
  - `config.keymaps`
  - `config.autocmds`
  - `plugins`
  - `config.completion`
  - `config.formatting`
  - `config.linting`
  - `config.lsp`

Config modules:

- `.config/nvim/lua/config/options.lua`: core Neovim options
- `.config/nvim/lua/config/keymaps.lua`: global keymaps, toggles, navigation, utility bindings
- `.config/nvim/lua/config/autocmds.lua`: autocmds
- `.config/nvim/lua/config/completion.lua`: `blink.cmp`, snippets, Supermaven
- `.config/nvim/lua/config/formatting.lua`: formatters and formatting behavior
- `.config/nvim/lua/config/linting.lua`: lint tooling
- `.config/nvim/lua/config/lsp.lua`: LSP setup, diagnostics, LSP-related keymaps
- `.config/nvim/lua/config/folds.lua`: folding helpers used by LSP detach/refresh

Plugin modules:

- `.config/nvim/lua/plugins/pack.lua`: add/remove plugins here
- `.config/nvim/lua/plugins/editor.lua`: configure editor-facing plugins such as Treesitter, Snacks, Gitsigns, Bufferline, markdown tools, statusline
- `.config/nvim/lua/plugins/theme.lua`: theme and highlight choices
- `.config/nvim/lua/plugins/init.lua`: plugin module loader

## Where To Edit

For common Neovim tasks, edit here first:

- New plugin or removing plugin: `.config/nvim/lua/plugins/pack.lua`
- Plugin setup or plugin keymap closely tied to a plugin: `.config/nvim/lua/plugins/editor.lua`
- Theme, highlight, colorscheme changes: `.config/nvim/lua/plugins/theme.lua`
- General non-LSP keymaps: `.config/nvim/lua/config/keymaps.lua`
- Completion behavior, `<C-y>`, snippets, AI completion: `.config/nvim/lua/config/completion.lua`
- LSP keymaps, diagnostics, code actions, rename, hover: `.config/nvim/lua/config/lsp.lua`
- Formatting behavior: `.config/nvim/lua/config/formatting.lua`
- Lint behavior: `.config/nvim/lua/config/linting.lua`
- Options like numbers, tabs, search, UI basics: `.config/nvim/lua/config/options.lua`
- Autocmd behavior: `.config/nvim/lua/config/autocmds.lua`

## Current Conventions

- Plugin installation uses native `vim.pack`, not `lazy.nvim`.
- Most user-facing notifications use `snacks.nvim`.
- Keep new mappings near related existing mappings.
- Prefer buffer-local mappings when a command only makes sense for one filetype.
- Do not split config into more files unless the existing structure is clearly too small for the change.

## Verification

For Neovim-only config changes, a good lightweight check is:

```sh
nvim --headless -i NONE '+qa'
```

If a change is isolated to one module, this is also useful:

```sh
nvim --headless -i NONE '+lua require("config.completion")' '+qa'
```
