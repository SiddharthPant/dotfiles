# Neovim guide

A quick reference for what the Neovim config adds on top of the vimrc. Leader is `<Space>`.
Press `<Space>` and wait, and which-key lists everything under it.

The config is a single file, `tools/nvim/posix/init.lua`, installed to `~/.config/nvim/init.lua` by `setup-tool install nvim`.
Plugins are pinned in `nvim-pack-lock.json` next to it; after `vim.pack.update()`, bring the new pins back with `setup-tool pull nvim`.

## LSP

Most of these are Neovim defaults; they only do something once a server is attached.

| Keys | Action |
|---|---|
| `K` | Hover docs |
| `gd` / `gD` | Go to definition / declaration |
| `grr` | References |
| `gri` / `grt` | Implementation / type definition |
| `grn` | Rename symbol |
| `gra` | Code action |
| `gO` | Document symbols in the location list |
| `<C-s>` (insert) | Signature help |
| `]d` / `[d` | Next / previous diagnostic |
| `<C-w>d` | Diagnostic under cursor in a float |
| `grx` | Run the code lens on this line |
| `<leader>ti` | Toggle inlay hints |

Renaming an HTML or templ open tag also renames its closing tag.

`:lsp restart` restarts the servers, `:checkhealth vim.lsp` shows what is attached, and `:Mason` manages installed servers.

## Go and templ

- Saving a `.go` file runs goimports: gofmt plus adding missing and dropping unused imports. `.templ` files run `templ fmt`.
- golangci-lint runs through its language server whenever a Go file is opened or saved, and its findings show up as diagnostics tagged with the linter name (`errcheck`, `staticcheck`, ...).
  It uses the project's `.golangci.yml` when there is one, otherwise its standard set (errcheck, govet, ineffassign, staticcheck, unused).
  For the whole module at once, run `golangci-lint run ./...` from `<leader>cc`.
- gopls keeps its default checks as you type. `<leader>ti` shows parameter names and inferred types inline.
- Code lenses appear as virtual text: "run test" above tests, and tidy or upgrade lines in `go.mod`. `grx` runs the one on the cursor line.
- In `.templ` files the HTML server completes tags and attributes and renames closing tags with opening ones; Go inside `{ ... }` goes through the templ server to gopls.
- gopls, goimports, golangci-lint and golangci-lint-langserver come from Homebrew; templ comes from the project's mise pin, so its LSP matches the generated code.
- `<leader>cc` defaults to `mise lint`, which in notices-srsalegal runs `go fmt ./...` and `go vet ./...`; `]e` / `[e` walk its errors.

## Completion (blink.cmp)

The menu does not pop up on its own, the same as the vimrc.

| Keys | Action |
|---|---|
| `<C-Space>` or `<C-n>` | Open the menu |
| `<Tab>` / `<S-Tab>` | Next / previous item (or snippet field) |
| `<C-y>` | Accept |
| `<C-e>` | Close |
| `<C-k>` | Toggle signature help |
| `<leader>ta` | Toggle auto-showing the menu while typing |

## Formatting (conform)

Files are formatted on save.

| Keys | Action |
|---|---|
| `<leader>cf` | Format buffer, or the selection in visual mode |
| `<leader>tf` | Toggle format on save |
| `gq{motion}` | Format a range through conform |

`:ConformInfo` shows which formatter runs for the current file.

## Treesitter: selections, motions and folds

| Keys | Action |
|---|---|
| `af` / `if` | Around / inside function (e.g. `daf`, `vif`) |
| `aa` / `ia` | Around / inside argument |
| `ac` / `ic` | Around / inside class |
| `]f` / `[f` | Next / previous function start |
| `]F` / `[F` | Next / previous function end |
| `<leader>a` / `<leader>A` | Swap argument with the next / previous one |
| `an` / `in` (visual) | Grow selection to the parent node / shrink to a child |
| `]n` / `[n` (visual) | Select the next / previous sibling node |

Folds come from treesitter and start open: `zc` / `zo` / `za` close, open and toggle one, `zM` / `zR` close and open all.

## Jumping (flash)

| Keys | Action |
|---|---|
| `s` | Type a char or two, then the label shown at the target |
| `S` | Pick a treesitter node by label and select it |
| `r` (after an operator) | Act somewhere else without moving: `yr`, label, then a motion such as `iw` |
| `R` (after an operator, or visual) | Treesitter search: pick a node around any match |
| `<C-s>` (in `/` search) | Toggle jump labels on search matches |

`f` / `t` / `;` / `,` still behave like plain Vim. `cl` substitutes a character, since `s` is taken.

## Multiple cursors

| Keys | Action |
|---|---|
| `<Up>` / `<Down>` | Add a cursor on the line above / below |
| `<leader>n` / `<leader>N` | Add a cursor at the next / previous match of the word or selection |
| `<leader>s` / `<leader>S` | Skip the next / previous match |
| `<leader>m` | Add cursors at every match |
| `<C-q>` | Drop a cursor here and pause all cursors; move, drop more, then `<Esc>` to resume |
| `<C-click>` | Add or remove a cursor with the mouse |

While several cursors exist: `<Left>` / `<Right>` cycle the main cursor, `<leader>x` deletes the main one, and `<Esc>` resumes paused cursors or else clears them all.
Any normal-mode edit or motion runs at every cursor.

## Git

In a buffer tracked by git (gitsigns):

| Keys | Action |
|---|---|
| `]c` / `[c` | Next / previous hunk |
| `<leader>gs` | Stage the hunk (again to unstage); in visual, stage only the selected lines |
| `<leader>gr` | Reset the hunk, or the selected lines |
| `<leader>go` | Preview the hunk inline |
| `<leader>gb` | Blame the line in a popup |
| `ih` | Hunk text object (e.g. `vih`, `dih`) |

Repository views:

| Keys | Action |
|---|---|
| `<leader>gg` | Neogit status in a new tab |
| `<leader>gd` | Toggle Diffview of the working tree |
| `<leader>gh` | Diffview history of this file; in visual, history of the selected lines |

Inside Neogit: `s` / `u` stage and unstage, `x` discard, `c` opens the commit popup (then `c` to commit), `p` pull, `P` push, `l` log, `d` diff in Diffview, `?` lists everything, `q` closes.
Diffview prefers jj in colocated repos, and `q` closes it.

## Build and run (compile-mode)

| Keys | Action |
|---|---|
| `<leader>cc` | `:Compile`: prompts for a command (defaults to `mise lint`) and runs it in `*compilation*` |
| `<leader>cr` | Run the last command again |
| `]e` / `[e` | Jump to the next / previous error from the output |

In the `*compilation*` buffer: `<CR>` opens the error under the cursor, `<Tab>` / `<S-Tab>` move between errors, `<C-r>` recompiles, `<C-c>` interrupts, `<C-q>` sends errors to the quickfix list, `q` closes.
Output keeps its ANSI colours (baleia). For any other buffer with raw colour codes, such as a log file, run `:BaleiaColorize`.

## Files (oil)

`-` opens the current file's directory as an editable buffer: rename or delete by editing lines, create by adding them, then `:w` to apply.
In oil, `<CR>` opens, `-` goes up, `_` jumps to the cwd, `g.` shows hidden files, `<C-p>` previews and `g?` lists the rest.
netrw is unchanged for `:Explore`, `:Lexplore` and opening directories.

## Built-in extras

| Keys / command | Action |
|---|---|
| `<leader>u` | `:Undotree`: browse the persistent undo history |
| `:DiffTool {left} {right}` | Diff two directories or files |
| `:restart` | Restart Neovim and keep the session's UI |
| `g<` | Reopen the last messages in the pager |
| `:Fidget history` | Past notifications |

## Maintenance

- `:lua vim.pack.update()` fetches plugin updates into a review tab; `:w` applies them, `:q` discards.
- `:TSUpdate` updates treesitter parsers (run automatically after nvim-treesitter updates).
- `:Mason` shows language servers and formatters; missing ones from the config are installed on startup.
