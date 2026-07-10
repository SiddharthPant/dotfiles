# Neovim Configuration

Compact single-file Neovim config. Entry point is `init.lua`; plugins use Neovim's native `vim.pack`. UX modules come from `mini.nvim`; snippets from `friendly-snippets`.

## Layout

- `init.lua` — bootstrap, options, core maps, pack, theme/UI, plugins (LoB), diagnostics, LSP
- `nvim-pack-lock.json` — lockfile managed by `vim.pack`; do not edit manually during normal use
- `.luarc.json` — LuaLS hints for editing this config

Sections in `init.lua` use marker folds (`-- Name {{{` … `-- }}}`) with nested plugin/LSP/autocmd subfolds. Modelines set `foldmethod=marker` and `foldlevel=0` (outline on open). Useful: `za` toggle, `zR`/`zM` open/close all, `zj`/`zk` next/prev fold.

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
- Plugins — treesitter, autotag, fff, grug-far, oil, conform, mini (nested)
- Diagnostics — config, jump/list maps, `<leader>td`
- LSP — Esc float clear, `LspAttach`, mason / lspconfig servers (nested)

## Plugin Management

Plugins are declared with `pack({ ... })` in `init.lua`.

`PackChanged` hooks (registered before `pack()`):

- `fff.nvim` — download/build its native binary on install/update
- `nvim-treesitter` — run `:TSUpdate` on install/update

If the fff binary is missing anyway:

```vim
:lua require("fff.download").download_or_build_binary()
```

Treesitter parsers are requested via `require("nvim-treesitter").install({ ... })` in `init.lua`. Askama templates under `templates/*.html` are detected as `htmldjango`; `nvim-ts-autotag` handles HTML tags.

### mini.nvim modules

Enabled from the full `mini.nvim` library:

| Module | Role |
|---|---|
| `mini.icons` | Icons (+ web-devicons mock, LSP kind tweak) |
| `mini.snippets` | Snippet engine + `friendly-snippets` loaders |
| `mini.completion` | Autocompletion / signature help (module defaults) |
| `mini.pairs` | Bracket/quote pairs (`{` disabled in template fts) |
| `mini.clue` | Which-key-style clues |
| `mini.diff` | Git hunk signs / overlay |
| `mini.sessions` | Session write/read/select |
| `mini.statusline` | Global statusline |

Also: `vim-fugitive` (`:Git`), `diffview-plus.nvim` (`:DiffviewOpen`, `:DiffviewFileHistory`, …).

Snippet expand/jump: `<C-k>` / `<C-l>` / `<C-h>`. Diff overlay: `<leader>go`. Sessions: per-cwd under `stdpath("data")/session`; auto-resume on start if present; auto-save on quit; `:Session` / `:SessionClear` (clear also skips save this quit).

### LSP / Mason

- `nvim-lspconfig` — default server configs (`cmd` / filetypes / root)
- `mason.nvim` — install UI (`:Mason`)
- `mason-lspconfig.nvim` — `ensure_installed` + `automatic_enable`

Server overrides live in the LSP Servers fold (`lua_ls` settings, custom `phpantom`). Mason ensures: `lua_ls`, `rust_analyzer`, `gopls`, `ts_ls`, `ty`.

To remove a plugin:

1. Remove its spec from `pack({ ... })`.
2. Restart Neovim.
3. Run:

```vim
:lua vim.pack.del({ "plugin-name.nvim" })
```

After this mini migration, inactive leftovers to delete if present:

```vim
:lua vim.pack.del({ "which-key.nvim", "nvim-autopairs", "mini.snippets" })
```

## Verification

```sh
nvim --headless -i NONE '+qa'
```
