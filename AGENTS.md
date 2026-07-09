# AGENTS.md

This repo contains personal dotfiles. The main actively used app config here is Neovim under `.config/nvim`.

## Managed By Makefile

`Makefile` is the source of truth for repo-managed links into `$HOME`.

Common links:

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

Platform-specific `~/.zshrc` links:

- `zshrc/macos/.zshrc` on macOS
- `zshrc/arch-i3/.zshrc` on Arch Linux

If a task touches setup or installation behavior, inspect `Makefile` first.

## Scope

- Make the smallest correct change.
- Prefer editing the existing file responsible for the behavior instead of creating new modules.
- For Neovim changes, edit `.config/nvim/init.lua` unless a dedicated file already exists for that concern. Do not split the config into more files unless the single-file layout is clearly too small for the change.

## Repo Layout

- `.tmux.conf`: tmux configuration
- `.gitconfig`: Git configuration
- `.zshenv`: non-interactive-safe Zsh environment and PATH setup
- `.config/nvim/`: Neovim configuration (single-file `init.lua`)
- `.config/ghostty/`: Ghostty terminal configuration
- `.config/kitty/`: Kitty terminal configuration
- `.config/zed/`: Zed editor configuration
- `.config/emacs/`: Emacs configuration
- `.config/starship.toml`: Starship prompt configuration
- `.config/mise/config.toml`: Global mise tools
- `.config/sqlfluff/.sqlfluff`: sqlfluff configuration
- `zshrc/macos/.zshrc`: macOS shell configuration
- `zshrc/arch-i3/.zshrc`: Arch Linux shell configuration

## Neovim Structure

For the Neovim-specific README, see `.config/nvim/README.md`.

Everything lives in `.config/nvim/init.lua`, roughly in this order:

1. Leader keys and `vim.loader`
2. Options
3. Keymaps and toggles
4. Autocmds (winbar, yank highlight, cursor restore, etc.)
5. Plugin install via `vim.pack.add` / `pack({ ... })`
6. Theme / highlight overrides
7. Plugin setup (fff, grug-far, oil, conform, which-key, fugitive)
8. Diagnostics, LSP completion, `LspAttach`, language servers
9. Snippets

Related files:

- `.config/nvim/init.lua`: the full Neovim config
- `.config/nvim/nvim-pack-lock.json`: `vim.pack` lockfile (do not hand-edit in normal use)
- `.config/nvim/.luarc.json`: LuaLS workspace hints for this config

## Where To Edit

For common Neovim tasks, edit the matching section of `.config/nvim/init.lua`:

- New plugin or removing plugin: the `pack({ ... })` list, then restart and `vim.pack.del` if needed (see `.config/nvim/README.md`)
- Plugins with install/build hooks (e.g. fff binary): register `PackChanged` **before** `pack()`
- Plugin setup or plugin-tied keymaps: near that plugin's `setup` / `require` block
- Theme, highlight, colorscheme: Nord + `apply_highlights` / `ColorScheme` autocmd
- General non-LSP keymaps and toggles: keymap section near the top
- LSP keymaps, diagnostics, servers: LSP and Diagnostics section
- Formatting: `conform.setup`
- Completion: `vim.lsp.completion` enable + `<C-Space>` map
- Snippets: `snippets` table and `<C-k>` / jump maps
- Options (numbers, tabs, search, UI): options block near the top
- Autocmd behavior: autocmd section (shared `group`)

## Git Conventions

- Commit messages must be a single one-line subject.
- Do not add `Co-authored-by` or any co-author trailers to commits.

## Current Conventions

- Plugin installation uses native `vim.pack`, not `lazy.nvim`.
- Keep the Neovim config in a single `init.lua` unless a split is clearly justified.
- Keep new mappings near related existing mappings.
- Prefer buffer-local mappings when a command only makes sense for one filetype.
- Prefer `vim.notify` for user-facing messages unless a plugin already owns that UI.
- Theme highlight overrides belong in `apply_highlights` so they survive `:colorscheme`.

## Verification

For Neovim-only config changes, a good lightweight check is:

```sh
nvim --headless -i NONE '+qa'
```
