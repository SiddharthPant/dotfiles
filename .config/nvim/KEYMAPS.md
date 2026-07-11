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

## Buffers and clipboard

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<leader>bd` | Delete the current buffer while keeping the split (`:bn` then delete the previous buffer) |
| Normal | `<leader>bo` | Close all other listed, unmodified buffers; modified buffers are left open |
| Normal | `<leader>tc` | Toggle OSC52 system-clipboard copying for future yanks and notify of the new state |

The clipboard toggle does not change the unnamed register. When enabled, a
normal yank (except to the black-hole register) is additionally copied through
OSC52.

## Files and search

| Mode | Keymap | Action |
|---|---|---|
| Normal | `-` | Open the Oil file explorer in the parent directory |
| Normal | `<leader><Space>` | Find files with fff.nvim |
| Normal | `<leader>/` | Live grep with fff.nvim using fuzzy and plain search modes |
| Normal | `<leader>fb` | Find buffers with mini.pick |
| Normal | `<leader>fh` | Search Neovim help with mini.pick |
| Normal | `<leader>fr` | Resume the previous mini.pick session |

## Git

These Gitsigns mappings are buffer-local and are available in Git-attached
buffers.

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<leader>tg` | Toggle current-line Git blame; a notification reports whether it is enabled or disabled |
| Normal | `<leader>go` | Preview the hunk under the cursor inline |

The inline hunk preview is cleared when the cursor moves, insert mode starts,
or the buffer is left.

These mappings are global:

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<leader>gg` | Open Neogit |
| Normal | `<leader>gd` | Toggle Diffview |

## Formatting and diagnostics

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<leader>cf` | Format the current buffer asynchronously with conform.nvim |
| Normal | `<leader>cx` | Open the location list with diagnostics for the current buffer |
| Normal | `<leader>cX` | Open the quickfix list with diagnostics for the whole workspace |
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

## Completion and special buffers

| Buffer / mode | Keymap | Action |
|---|---|---|
| Insert | `<CR>` | Accept the selected completion item; if none is selected, dismiss the popup and insert an autopairs-aware newline |
| Quickfix, normal | `q` | Close the quickfix window |

The completion `<CR>` mapping is global, but its behavior changes depending on
whether the completion menu is visible and whether an item is selected.
