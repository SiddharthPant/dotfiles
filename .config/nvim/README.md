# Neovim

Main config: `init.lua`; Askama snippets live in `snippets/askama.json`.
Plugins via native `vim.pack`. UX from Snacks and focused community plugins; completion from blink.cmp.

## Conventions

- **Locality of Behaviour** — plugin setup, maps, and related autocmds live together in one fold.
- **Marker folds** — navigate with `za` / `zR` / `zM`. Do not add leader maps for simple Ex commands (`:Mason`, `:Markview`, …).
- Edit `init.lua` unless a dedicated file already exists (e.g. `.luarc.json`).

## Gotchas

- Register `PackChanged` hooks **before** `pack()` (fff binary and treesitter `TSUpdate`).
- `templates/*.html` becomes `askama` when an ancestor `Cargo.toml` uses
  Askama, `htmldjango` in Django projects, and plain `html` otherwise.
- `askama` uses `lpnh/tree-sitter-askama`; `htmldjango` retains its dedicated
  parser.
- Blink's native snippet source loads Askama snippets from `snippets/` and
  explicitly adds friendly-snippets' generic HTML collection. Django snippets
  remain exclusive to `htmldjango`. Zen mode only shows snippets automatically;
  `<C-Space>` requests all completion sources. `<CR>` accepts an explicitly
  selected item, while `<Tab>` / `<S-Tab>` navigate snippets.
- Mason ensures configured LSPs and formatter/linter binaries; `rustfmt` remains
  supplied by the Rust toolchain because it is not in Mason's registry.
- AutoSession stores per-cwd sessions under `stdpath("data")/sessions` (not in
  the project tree) and re-detects template filetypes after restoring stale
  local options. `:SessionClear` also skips save on that quit.

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
| Keymaps | [KEYMAPS.md](KEYMAPS.md) |
| Completion | blink.cmp with native snippets for LSP, paths, snippets, buffer words, and `:` commands |
| UI | Snacks, lualine, and nvim-web-devicons |
| Herdr panes | `<C-h/j/k/l>` navigates; `<M-h/j/k/l>` resizes across Neovim and Herdr |
| Sessions | AutoSession restores/saves by cwd; `:Session` / `:SessionClear` |
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
