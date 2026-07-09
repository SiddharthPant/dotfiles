# Neovim Configuration

Compact single-file Neovim config. Entry point is `init.lua`; plugins use Neovim's native `vim.pack`.

## Layout

- `init.lua` — options, keymaps, autocmds, plugin declarations/setup, theme, LSP, completion, and snippets
- `nvim-pack-lock.json` — lockfile managed by `vim.pack`; do not edit manually during normal use
- `.luarc.json` — LuaLS hints for editing this config

Rough section order in `init.lua`:

1. Leader keys / `vim.loader`
2. Options
3. Keymaps and toggles
4. Autocmds
5. `pack({ ... })` plugin list
6. Theme and highlight overrides
7. Plugin setup
8. Diagnostics / LSP / language servers
9. Snippets

## Plugin Management

Plugins are declared with `pack({ ... })` in `init.lua`.

`fff.nvim` needs a native binary. A `PackChanged` autocmd (registered before `pack()`) runs `require("fff.download").download_or_build_binary()` on install/update. If the binary is missing anyway:

```vim
:lua require("fff.download").download_or_build_binary()
```

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

## Verification

```sh
nvim --headless -i NONE '+qa'
```
