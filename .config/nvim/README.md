# Neovim

Main config: `init.lua`; Askama snippets live in `lua/snippets/htmldjango.lua`.
Plugins via native `vim.pack`. UX from `mini.nvim`.

## Conventions

- **Locality of Behaviour** — plugin setup, maps, and related autocmds live together in one fold.
- **Marker folds** — navigate with `za` / `zR` / `zM`. Do not add leader maps for simple Ex commands (`:Mason`, `:Git`, `:Markview`, …).
- Edit `init.lua` unless a dedicated file already exists (e.g. `.luarc.json`).

## Gotchas

- Register `PackChanged` hooks **before** `pack()` (fff binary, treesitter `TSUpdate`).
- Askama `templates/*.html` → `htmldjango`.
- Askama blocks use `<C-k>` snippets; standard autopairs provide the brace pairing
  around template expressions and tags.
- Sessions are per-cwd under `stdpath("data")/session` (not in the project tree). `:SessionClear` also skips save on that quit.
- Markdown colors for markview are overridden in the Theme fold (Nord’s default `@markup.heading.*` are all green).

## Remove a plugin

1. Remove its spec from `pack({ ... })` in `init.lua`.
2. Restart Neovim.
3. Delete the installed package:

```vim
:lua vim.pack.del({ "plugin-name.nvim" })
```

## Quick reference

| Area | Notes |
|---|---|
| Snippets | `<C-k>` expand, `<C-l>` / `<C-h>` jump |
| Diff overlay | `<leader>go` |
| Sessions | auto on start/quit; `:Session` / `:SessionClear` |
| Git | `:Git`, `:DiffviewOpen`, `:DiffviewFileHistory` |
| Markdown | `:Markview` |
| LSP install | `:Mason` — ensures `lua_ls`, `rust_analyzer`, `gopls`, `ts_ls`, `ty` |
| fff binary missing | `:lua require("fff.download").download_or_build_binary()` |

## Check

```sh
nvim --headless -i NONE '+qa'
```
