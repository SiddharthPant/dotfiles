# Neovim keymaps

The leader is `<Space>` and the local leader is `,`.

Mappings listed as **buffer-local** are created only for buffers where the
relevant plugin or file type is active. This file documents custom mappings in
`.config/nvim/init.lua` plus selected plugin and built-in shortcuts.

## Core editing

| Mode | Keymap | Action |
|---|---|---|
| Terminal | `<Esc><Esc>` | Leave terminal mode and return to normal mode |
| Normal | `<leader>rr` | Restart Neovim (`:restart`) |
| Normal | `j` | Move down by display line (`gj`) when no count is given; use normal `j` with a count |
| Normal | `k` | Move up by display line (`gk`) when no count is given; use normal `k` with a count |
| Normal | `n` | Go to the next search match and center it |
| Normal | `N` | Go to the previous search match and center it |
| Normal | `<C-d>` | Scroll down half a page and center the cursor |
| Normal | `<C-u>` | Scroll up half a page and center the cursor |
| Normal | `<leader>zj` | Close the current fold, move to the next fold, and open it |
| Normal | `<leader>zk` | Close the current fold, move to the previous fold, and open it |
| Normal | `<leader>th` | Toggle hidden-character display and notify of the new state |
| Normal | `J` | Join lines while preserving the cursor's position |
| Visual | `<` | Indent left and keep the selection active |
| Visual | `>` | Indent right and keep the selection active |

## Neovim and tmux panes

These vim-tmux-navigator mappings move seamlessly across Neovim splits and tmux panes.

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<C-h>` | Navigate left |
| Normal | `<C-j>` | Navigate down |
| Normal | `<C-k>` | Navigate up |
| Normal | `<C-l>` | Navigate right |
| Normal | `<C-\>` | Navigate to the previous split or pane |

## Buffers and clipboard

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<leader>bd` | Delete the current unmodified buffer while preserving every split and tab displaying it |
| Normal | `<leader>bo` | Close all other listed, unmodified buffers and notify how many were closed or retained as modified |
| Normal | `<leader>tc` | Toggle OSC52 system-clipboard copying for future yanks and notify of the new state |

The clipboard toggle does not change the unnamed register. When enabled, a
normal yank (except to the black-hole register) is additionally copied through
OSC52.

## Files and search

| Mode | Keymap | Action |
|---|---|---|
| Normal | `-` | Open the Oil file explorer in the parent directory |
| Normal | `<leader><Space>` | Find project files with FzfLua, ordered by proximity to the current file when available |
| Normal | `<leader><BS>` | Find open buffers with FzfLua |
| Normal | `<leader>/` | Live grep with FzfLua |
| Normal | `<leader>?` | Grep for the word under the cursor with FzfLua |
| Normal | `<leader>fh` | Search Neovim help with FzfLua |
| Normal | `<leader>fr` | Resume the previous FzfLua picker |

Opening a file automatically changes Neovim's working directory to the nearest
Git, Mercurial, or Subversion root.

Search highlights clear automatically on entering Insert mode or after an idle
period controlled by `updatetime`, via the bundled `nohlsearch` plugin.

## Git

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<leader>gg` | Toggle Diffview Plus for the working tree |
| Normal, buffer-local | `<leader>go` | Preview the Git hunk under the cursor inline |
| Normal, Diffview-local | `q` | Close the current Diffview tab |

## Motion

| Mode | Keymap | Action |
|---|---|---|
| Normal, Visual, Operator-pending | `s` | Leap bidirectionally to a labeled target in the current window |

## Tree-sitter text objects

Available buffer-locally for configured parsers with text-object queries:

| Mode | Keymap | Action |
|---|---|---|
| Visual, Operator-pending | `af` / `if` | Around/inside a function |
| Visual, Operator-pending | `aa` / `ia` | Around/inside an argument or parameter |
| Visual, Operator-pending | `ac` / `ic` | Around/inside a class or struct, where supported |
| Normal, Visual, Operator-pending | `]f` / `[f` | Next/previous function start |
| Normal, Visual, Operator-pending | `]F` / `[F` | Next/previous function end |
| Normal | `<leader>a` / `<leader>A` | Swap the current argument/parameter with the next/previous one |

For example, `vaf` selects a function and `cif` changes its body. Selection looks
ahead when the cursor is not already inside a matching object.

## Completion

Blink uses its default insert-mode and command-line keymap presets. In insert mode,
preselection and automatic insertion are enabled. `<C-Space>` opens suggestions or
documentation, `<C-n>` / `<C-p>` select the next/previous item, `<C-y>` accepts,
and `<C-e>` cancels the preview. Sources are LSP, paths, Friendly Snippets, and buffer words.
After accepting a snippet, `<Tab>` / `<S-Tab>` move forward/backward between
placeholders using Blink's snippet mappings and Neovim's snippet engine.
Enter is not mapped by Blink and inserts a normal newline.

In the command line, `<Tab>` / `<S-Tab>` open completion and insert/cycle matches
(a sole match may be accepted immediately). `<C-n>` / `<C-p>` navigate,
`<C-y>` accepts, and `<C-e>` cancels. The popup opens automatically as you type
in the command line, with nothing preselected; the first `<Tab>` selects and
inserts the first match.

## LSP

`gd` goes to a definition in LSP-attached buffers. Neovim's standard LSP mappings
remain available: `K` for hover, `grn` for rename, `grr` for references, `gra` for
code actions, `gri` for implementations, and `[d` / `]d` for diagnostic navigation.
Diagnostics appear as virtual lines beneath the current cursor line.
Inlay hints are enabled by default. `<leader>ti` toggles them for the current
buffer when its language server supports hints.
