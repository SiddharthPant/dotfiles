# Neovim Configuration

This is a compact, single-file Neovim configuration. The entry point is `init.lua`, and plugins are managed with Neovim's native `vim.pack` package manager.

## Layout

- `init.lua` — options, keymaps, autocmds, plugin declarations, plugin setup, LSP, completion, and snippets.
- `nvim-pack-lock.json` — lockfile managed by `vim.pack`; do not edit manually during normal use.

## Plugin Management

Plugins are declared with `pack({ ... })` in `init.lua`.

To remove a plugin:

1. Remove its spec from `pack({ ... })`.
2. Restart Neovim.
3. Run:

```vim
:lua vim.pack.del({ "plugin-name.nvim" })
```

Example:

```vim
:lua vim.pack.del({ "diffview-plus.nvim" })
```

To list installed plugins that are no longer active:

```vim
:lua =vim.iter(vim.pack.get()):filter(function(x) return not x.active end):map(function(x) return x.spec.name end):totable()
```
