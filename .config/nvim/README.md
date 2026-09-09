# Neovim

Main config: `init.lua`. Plugins use native `vim.pack`; Blink handles insert-mode
and command-line completion. Neovim's LSP client uses `nvim-lspconfig` defaults
and Mason-managed language servers. Conform handles format-on-save.

## Conventions

- **Locality of behaviour** — keep plugin setup, maps, and related autocmds together.
- Do not add leader maps for commands that are already easy to invoke.
- Edit `init.lua` unless a dedicated file already exists (e.g. `.luarc.json`).

## Gotchas

- `<leader><Space>` uses `fd` and, when a file is open, `proximity-sort` to rank nearby
  project files first. FzfLua, `fd`, `fzf`, and `proximity-sort` are provided by
  the Neovim plugin list, Homebrew, and Mise respectively.
- Neovim detects `templates/*.html` as `htmldjango` and uses its built-in
  template syntax with HTML indentation. These templates are excluded from
  format-on-save; plain HTML parsers/formatters are not applied to them.
- AutoSession stores per-cwd sessions under `stdpath("data")/sessions` (not in
  the project tree). `:SessionClear` also skips save on that quit.
- `:Compile` defaults to `mise lint` and renders ANSI-colored output; use
  `:Recompile` globally or `<C-r>` in the compilation buffer to run it again
  after making changes. Recompiling interrupts an active run without prompting,
  and error navigation wraps at either end.

## Remove a plugin

1. Remove its spec from `vim.pack.add({ ... })` in `init.lua`.
2. Restart Neovim.
3. Delete the installed package:

```vim
:lua vim.pack.del({ "plugin-name.nvim" })
```

## Quick reference

| Area | Notes |
|---|---|
| Keymaps | [KEYMAPS.md](KEYMAPS.md) |
| Completion | Blink: automatic LSP/path/snippet/buffer suggestions and command-line completion; no native completion fallback |
| Highlighting | Tree-sitter parsers for Rust, Lua, web files, shell, TOML, YAML, Markdown, and Vim help; rainbow delimiters use Catppuccin colors |
| LSP | Rust, Lua, TypeScript/JavaScript, HTML, CSS, JSON, shell, TOML, YAML; `:checkhealth vim.lsp` |
| Formatting | Conform on save; `:ConformInfo` shows the formatter selected for this buffer |
| Navigation | FzfLua pickers, Oil explorer, Leap motions, and automatic project-root cwd |
| Git | Gitsigns inline hunk previews and Diffview Plus working-tree review |
| Tmux panes | vim-tmux-navigator uses `<C-h/j/k/l>` and `<C-\>` across Neovim and tmux |
| Sessions | AutoSession restores/saves by cwd; `:Session` / `:SessionClear` |

## Check

Friendly Snippets supplies snippets to Blink, which uses Neovim's `vim.snippet`
engine for expansion and placeholder navigation. Select a snippet with `Ctrl-n` /
`Ctrl-p`, accept with `Enter` or `Ctrl-y`, then use `Tab` / `Shift-Tab` between placeholders.
Custom snippets can be added in VS Code JSON format under `snippets/`, with a
`package.json` declaring their filetypes and paths. LuaSnip is not required.

Requires Neovim 0.12+, Git, curl, a C compiler, and tree-sitter-cli 0.26.1+.
Mason's npm-based packages also require Node/npm. Rust formatting uses `rustfmt`
from the project's Rust toolchain. Blink is pinned to a release and requires its
Rust fuzzy matcher; it downloads the matching binary on first launch.

On first launch, keep Neovim open while parsers and Mason tools install, then
reopen buffers (or restart). `:Mason` shows installed tools. Language servers
install through `mason-lspconfig`; `mason-tool-installer` installs StyLua,
Prettier, shfmt, and Taplo. Their install lists are in `init.lua`.

`treesitter_parsers` controls both parser installation and highlighting. Each
buffer's filetype is resolved through Neovim's Tree-sitter language mappings,
so aliases such as `typescriptreact` and `sh` need no separate filetype list.

Conform formats supported ordinary file buffers before saving, with a two-second
timeout and no LSP formatting fallback. It uses project formatter configuration
where supported. No second LSP format-on-save hook is configured.

Update plugins with `:lua vim.pack.update()`. Tree-sitter parser updates run
after its plugin updates; `:TSUpdate` can also be run manually. Use `:Mason` to
update servers and `:MasonToolsUpdate` to update managed formatters. Plugin
revisions are locked in `nvim-pack-lock.json`; Mason tool versions are not.

Useful checks: `:checkhealth mason`, `:checkhealth vim.lsp`,
`:checkhealth nvim-treesitter`, `:checkhealth blink.cmp`, and `:ConformInfo`.

```sh
nvim --headless -i NONE '+qa'
```
