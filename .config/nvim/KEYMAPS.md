# Neovim keymaps

The leader is `<Space>` and the local leader is `,`.

Mappings listed as **buffer-local** are created only for buffers where the
relevant plugin or file type is active. Plugin-provided default mappings are
not listed here; this file documents mappings defined explicitly in
`.config/nvim/init.lua`.

## Core editing

| Mode | Keymap | Action |
|---|---|---|
| Terminal | `<Esc><Esc>` | Leave terminal mode and return to normal mode |
| Normal | `<leader>qq` | Quit all Neovim windows (`:qall`) |
| Normal | `j` | Move down by display line (`gj`) when no count is given; use normal `j` with a count |
| Normal | `k` | Move up by display line (`gk`) when no count is given; use normal `k` with a count |
| Normal | `n` | Go to the next search match and center it |
| Normal | `N` | Go to the previous search match and center it |
| Normal | `<C-d>` | Scroll down half a page and center the cursor |
| Normal | `<C-u>` | Scroll up half a page and center the cursor |
| Normal | `<leader>th` | Toggle hidden-character display and notify of the new state |
| Normal | `J` | Join lines while preserving the cursor's position |
| Normal | `<A-j>` | Move the current line down and reindent it |
| Normal | `<A-k>` | Move the current line up and reindent it |
| Visual | `<A-j>` | Move the selected lines down and reselect them |
| Visual | `<A-k>` | Move the selected lines up and reselect them |
| Visual | `<` | Indent left and keep the selection active |
| Visual | `>` | Indent right and keep the selection active |

### Macros

| Mode | Keymap | Action |
|---|---|---|
| Normal | `Q` | Start recording a macro; this is an alias for the usual `q` command |
| Normal | `q` | Disabled to prevent accidental macro recording |

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
| Normal | `<leader>bd` | Delete the current buffer while keeping the split (`:bn` then delete the previous buffer) |
| Normal | `<leader>bo` | Close all other listed, unmodified buffers and notify how many were closed or retained as modified |
| Normal | `<leader>tc` | Toggle OSC52 system-clipboard copying for future yanks and notify of the new state |

The clipboard toggle does not change the unnamed register. When enabled, a
normal yank (except to the black-hole register) is additionally copied through
OSC52.

## Files and search

| Mode | Keymap | Action |
|---|---|---|
| Normal | `-` | Open the Oil file explorer in the parent directory |
| Normal | `<leader>e` | Open the Snacks project tree explorer with hidden and ignored files shown |
| Normal | `<C-p>` | Find project files with FzfLua, ordered by proximity to the current file when available |
| Normal | `<leader><Space>` | Switch to the previously used alternate buffer |
| Normal | `<leader>;` | Find open buffers with FzfLua |
| Normal | `<leader>/` | Live grep with FzfLua |
| Normal | `<leader>fh` | Search Neovim help with FzfLua |
| Normal | `<leader>fs` | Find symbols in the current buffer with FzfLua |
| Normal | `<leader>fS` | Find symbols in the workspace with FzfLua |
| Normal | `<leader>fr` | Resume the previous FzfLua picker |
| Normal | `<leader>fx` | Find diagnostics in the current buffer with FzfLua |
| Normal | `<leader>fX` | Find workspace diagnostics with FzfLua |

Opening a file automatically changes Neovim's working directory to the nearest
Git, Mercurial, or Subversion root.

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

## Formatting and diagnostics

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<leader>cf` | Format the current buffer asynchronously with conform.nvim |
| Normal | `<leader>td` | Toggle diagnostics globally and notify of the new state |

## LSP

These mappings are buffer-local and are created when an attached LSP client
supports the corresponding method.

| Mode | Keymap | Action |
|---|---|---|
| Normal | `gd` | Go to definition |
| Normal | `gD` | Go to declaration |

The following mapping is global:

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<Esc>` | Close open LSP floating previews and clear search highlighting |

## Completion

Insert completion never opens automatically or preselects an item. Use
Neovim's built-in `<C-x><C-o>` to request LSP completion, `<C-n>` / `<C-p>`
to move through candidates, `<C-y>` to accept, and `<C-e>` to cancel.

Command-line completion also uses Neovim's defaults: `<Tab>` starts or moves
forward through fuzzy completion, while `<S-Tab>` moves backward. `<C-n>` and
`<C-p>` also move through an open menu.
