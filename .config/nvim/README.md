# Neovim

Main config: `init.lua`. Plugins use native `vim.pack`; completion uses Neovim's
built-in command-line and LSP support.

## Conventions

- **Locality of behaviour** — keep plugin setup, maps, and related autocmds together.
- Do not add leader maps for commands that are already easy to invoke (`:Mason`, `:Markview`, …).
- Edit `init.lua` unless a dedicated file already exists (e.g. `.luarc.json`).

## Gotchas

- Register `PackChanged` hooks **before** `pack()` so treesitter `TSUpdate` runs
  after install and update.
- `<C-p>` uses `fd` and, when a file is open, `proximity-sort` to rank nearby
  project files first. FzfLua, `fd`, `fzf`, and `proximity-sort` are provided by
  the Neovim plugin list, Homebrew, and Mise respectively.
- `templates/*.html` becomes `askama` when an ancestor `Cargo.toml` uses
  Askama, `htmldjango` in Django projects, and plain `html` otherwise.
- `askama` uses `lpnh/tree-sitter-askama`; `htmldjango` retains its dedicated
  parser.
- Askama templates are formatted with `askama_fmt`; Django templates continue
  to use `djlint`.
- Insert completion is manual, LSP-only, excludes snippets, and does not preselect an item:
  `<C-x><C-o>` opens it, `<C-n>` / `<C-p>` move through candidates, `<C-y>`
  accepts, and `<C-e>` cancels.
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
| Completion | Manual native LSP completion with `<C-x><C-o>`; fuzzy built-in completion for `:` commands |
| Navigation | FzfLua pickers, Snacks explorer, Leap motions, and automatic project-root cwd |
| Git | Gitsigns inline hunk previews and Diffview Plus working-tree review |
| Tmux panes | vim-tmux-navigator uses `<C-h/j/k/l>` and `<C-\>` across Neovim and tmux |
| Sessions | AutoSession restores/saves by cwd; `:Session` / `:SessionClear` |
| Markdown | `:Markview` |
| SQL | Four-space indentation; SQLFluff formatting/linting defaults to PostgreSQL |
| Linting | Checkmake for Makefiles; dotenv-linter for `.env*` |
| Python | Ty LSP; Ruff formatting and lint diagnostics |
| Shell | BashLS uses Mason-installed ShellCheck; `env` files are excluded |
| Rust | rust-analyzer with Clippy diagnostics; rustfmt formatting |
| Tool install | `:Mason` — LSPs and non-Rust formatter/linter binaries |

## Check

```sh
nvim --headless -i NONE '+qa'
```
