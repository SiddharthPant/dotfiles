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

## Neovim and Herdr panes

These mappings move and resize seamlessly across Neovim splits and Herdr panes.

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<C-h>` | Navigate left |
| Normal | `<C-j>` | Navigate down |
| Normal | `<C-k>` | Navigate up |
| Normal | `<C-l>` | Navigate right |
| Normal | `<M-h>` | Resize left |
| Normal | `<M-j>` | Resize down |
| Normal | `<M-k>` | Resize up |
| Normal | `<M-l>` | Resize right |

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
| Normal | `<leader>e` | Toggle the Snacks tree explorer (including hidden and Git-ignored files) |
| Normal | `<leader><Space>` | Find files with fff.nvim |
| Normal | `<leader>/` | Live grep with fff.nvim using fuzzy and plain search modes |
| Normal | `<leader>fb` | Find buffers with Snacks picker |
| Normal | `<leader>fh` | Search Neovim help with Snacks picker |
| Normal | `<leader>fs` | Find symbols in the current buffer with Snacks picker |
| Normal | `<leader>fS` | Find symbols in the workspace with Snacks picker |
| Normal | `<leader>fr` | Resume the previous Snacks picker |
| Normal | `<leader>fx` | Find diagnostics in the current buffer with Snacks picker |
| Normal | `<leader>fX` | Find workspace diagnostics with Snacks picker |

## Git

These Gitsigns mappings are buffer-local and are available in Git-attached
buffers.

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<leader>tg` | Toggle current-line Git blame; a notification reports whether it is enabled or disabled |
| Normal | `<leader>go` | Preview the hunk under the cursor inline |
| Normal | `<leader>gx` | Open changed hunks for the current buffer in Trouble |
| Normal | `<leader>gX` | Open all changed Git hunks in Trouble |

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
| Normal | `<leader>cx` | Toggle Trouble diagnostics for the current buffer |
| Normal | `<leader>cX` | Toggle Trouble diagnostics for the whole workspace |
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

| Mode | Keymap | Action |
|---|---|---|
| Normal | `<leader>tz` | Toggle zen mode (enabled by default), which limits automatic completion to snippets |

In zen mode, snippet matches open automatically while LSP, path, and buffer
suggestions stay hidden. `<C-Space>` explicitly requests all sources. Blink
otherwise uses its enter keymap preset without preselecting the first item.
`<CR>` accepts an explicitly selected completion; otherwise it remains an
autopairs-aware newline. `<Up>` / `<Down>` and `<C-p>` / `<C-n>` select items.
`<Tab>` expands a matching native snippet or jumps forward through placeholders,
while `<S-Tab>` jumps backward; otherwise both fall back to their normal
behavior. They do not cycle completion items.

Blink completes from LSP, paths, native snippets, and buffer words. For `:`
command-line completion, the menu opens automatically without selecting an
item; `<Tab>` / `<S-Tab>` cycle items, and `<C-y>` accepts the selection.
