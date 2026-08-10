# Neovim

Main config: `init.lua`. Plugins use native `vim.pack`; completion uses Neovim's
built-in insert-mode and command-line support.

## Conventions

- **Locality of behaviour** — keep plugin setup, maps, and related autocmds together.
- Do not add leader maps for commands that are already easy to invoke.
- Edit `init.lua` unless a dedicated file already exists (e.g. `.luarc.json`).

## Gotchas

- `<C-p>` uses `fd` and, when a file is open, `proximity-sort` to rank nearby
  project files first. FzfLua, `fd`, `fzf`, and `proximity-sort` are provided by
  the Neovim plugin list, Homebrew, and Mise respectively.
- Neovim detects `templates/*.html` as `htmldjango` and uses its built-in
  template syntax with HTML indentation.
- AutoSession stores per-cwd sessions under `stdpath("data")/sessions` (not in
  the project tree). `:SessionClear` also skips save on that quit.
- `:Compile` defaults to `mise lint` and renders ANSI-colored output; use
  `:Recompile` globally or `<C-r>` in the compilation buffer to run it again
  after making changes. Recompiling interrupts an active run without prompting,
  and error navigation wraps at either end.

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
| Completion | Built-in insert-mode and fuzzy `:` command completion |
| Navigation | FzfLua pickers, Oil explorer, Leap motions, and automatic project-root cwd |
| Git | Gitsigns inline hunk previews and Diffview Plus working-tree review |
| Tmux panes | vim-tmux-navigator uses `<C-h/j/k/l>` and `<C-\>` across Neovim and tmux |
| Sessions | AutoSession restores/saves by cwd; `:Session` / `:SessionClear` |

## Check

```sh
nvim --headless -i NONE '+qa'
```
