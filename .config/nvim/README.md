# Neovim Configuration

Compact single-file Neovim config. Entry point is `init.lua`; plugins use Neovim's native `vim.pack`. Snippet bodies live under `lua/snippets/`.

## Layout

- `init.lua` — bootstrap, options, core maps, pack, theme/UI, plugins (LoB), diagnostics, LSP, snippet keymaps
- `lua/snippets/` — per-language snippet bodies + thin loader (`require("snippets")`)
- `nvim-pack-lock.json` — lockfile managed by `vim.pack`; do not edit manually during normal use
- `.luarc.json` — LuaLS hints for editing this config

Sections in `init.lua` use marker folds (`-- Name {{{` … `-- }}}`) with nested plugin/LSP/autocmd subfolds. Same style in `lua/snippets/`. Modelines set `foldmethod=marker` and `foldlevel=0` (outline on open). Useful: `za` toggle, `zR`/`zM` open/close all, `zj`/`zk` next/prev fold.

Top-level folds (Locality of Behaviour: setup + maps for a feature stay together):

- Bootstrap — loader, leaders, `map` / `pack` / augroup
- Options — including `completeopt`, title
- Core editing — wrap-aware motion, search/scroll center, Alt move, indent, macros
- Buffers — `bd` / `bo`
- Clipboard — OSC52 + toggles (`tc`, `tw`)
- Pack — fff binary hook + `pack({ ... })`
- Theme — colorscheme + highlight overrides
- UI chrome — inactive winbar, completion doc styling
- General autocmds — cursor restore, yank, qf, gitcommit
- Plugins — which-key, fff, grug-far, oil, conform (nested per plugin)
- Diagnostics — config, jump/list maps, `<leader>td`
- LSP — Esc float clear, completion, `LspAttach`, servers (nested)
- Snippets — expand/jump maps only (bodies in `lua/snippets/`)

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

## Snippets

Add or edit a language file under `lua/snippets/` (e.g. `go.lua` returns `{ err = "..." }`), then register it in `lua/snippets/init.lua` if it is new. Expand with `<C-k>`, jump with `<C-l>` / `<C-h>`.

## Verification

```sh
nvim --headless -i NONE '+qa'
```
