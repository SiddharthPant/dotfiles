# Neovim Config

This directory contains the Neovim configuration managed by the repo `Makefile` and linked to `~/.config/nvim`.

## Entry Point

- `init.lua`: loads config in this order:
  - `config.options`
  - `config.keymaps`
  - `config.autocmds`
  - `plugins`
  - `config.completion`
  - `config.formatting`
  - `config.linting`
  - `config.lsp`

## Folder Layout

- `lua/config/options.lua`: core editor options
- `lua/config/keymaps.lua`: global keymaps and toggles
- `lua/config/autocmds.lua`: autocommands
- `lua/config/completion.lua`: completion, snippets, and Supermaven
- `lua/config/formatting.lua`: formatting setup
- `lua/config/linting.lua`: linting setup
- `lua/config/lsp.lua`: LSP, diagnostics, and LSP-related keymaps
- `lua/config/folds.lua`: fold helpers used by LSP attach/detach flows
- `lua/plugins/pack.lua`: plugin declarations via `vim.pack`
- `lua/plugins/editor.lua`: editor-facing plugin setup
- `lua/plugins/theme.lua`: colorscheme and highlight config
- `lua/plugins/init.lua`: plugin loader

## Where To Edit

- Add or remove a plugin: `lua/plugins/pack.lua`
- Configure a plugin or plugin-specific keymap: `lua/plugins/editor.lua`
- Change colors or highlights: `lua/plugins/theme.lua`
- Change general keymaps: `lua/config/keymaps.lua`
- Change completion or AI suggestion behavior: `lua/config/completion.lua`
- Change diagnostics or LSP behavior: `lua/config/lsp.lua`
- Change formatting: `lua/config/formatting.lua`
- Change linting: `lua/config/linting.lua`
- Change options: `lua/config/options.lua`
- Change autocmds: `lua/config/autocmds.lua`

## Conventions

- Keep changes as small as possible.
- Prefer editing the existing responsible file instead of creating a new one.
- Use `snacks.nvim` for user-facing notifications when it matches existing patterns.
- Prefer buffer-local mappings when a command only applies to one filetype.

## Verification

```sh
nvim --headless -i NONE '+qa'
```

For a single module:

```sh
nvim --headless -i NONE '+lua require("config.completion")' '+qa'
```
