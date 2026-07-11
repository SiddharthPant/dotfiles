# Neovim

Main config: `init.lua`; Askama snippets live in `lua/snippets/htmldjango.lua`.
Plugins via native `vim.pack`. UX from `mini.nvim`.

## Conventions

- **Locality of Behaviour** — plugin setup, maps, and related autocmds live together in one fold.
- **Marker folds** — navigate with `za` / `zR` / `zM`. Do not add leader maps for simple Ex commands (`:Mason`, `:Markview`, …).
- Edit `init.lua` unless a dedicated file already exists (e.g. `.luarc.json`).

## Gotchas

- Register `PackChanged` hooks **before** `pack()` (fff binary, treesitter `TSUpdate`).
- Askama `templates/*.html` → `htmldjango`.
- Askama blocks use `<C-k>` snippets; standard autopairs provide the brace pairing
  around template expressions and tags.
- Mason ensures configured LSPs and formatter/linter binaries; `rustfmt` remains
  supplied by the Rust toolchain because it is not in Mason's registry.
- Sessions are per-cwd under `stdpath("data")/session` (not in the project tree). `:SessionClear` also skips save on that quit.

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
| Find | `<leader>fb` buffers, `<leader>fh` help, `<leader>fr` resume picker |
| Git hunk preview | `<leader>go` |
| Sessions | auto on start/quit; `:Session` / `:SessionClear` |
| Git | `<leader>gg` Neogit, `<leader>gd` Diffview, `<leader>tg` line blame |
| Markdown | `:Markview` |
| SQL | Four-space indentation; SQLFluff formatting/linting defaults to PostgreSQL |
| Linting | Checkmake for Makefiles; dotenv-linter for `.env*` |
| Python | Ty LSP; Ruff formatting and lint diagnostics |
| Shell | BashLS uses Mason-installed ShellCheck; `env` files are excluded |
| Rust | rust-analyzer with Clippy diagnostics; rustfmt formatting |
| Tool install | `:Mason` — LSPs and non-Rust formatter/linter binaries |
| fff binary missing | `:lua require("fff.download").download_or_build_binary()` |

## Check

```sh
nvim --headless -i NONE '+qa'
```
