# Neovim Keymap Reference

Leader is `<Space>`. Localleader is `,`.

This is a ready reference for custom mappings in this config, plus the Neovim
defaults that the config intentionally relies on.

## Completion And AI

| Mode | Key | Action |
|------|-----|--------|
| Insert | `<C-Space>` | Show/hide completion menu |
| Insert | `<CR>` | Accept selected completion item |
| Insert | `<C-n>` | Select next completion item |
| Insert | `<C-p>` | Select previous completion item |
| Insert | `<Tab>` | Select next completion item, then snippet forward, then fallback |
| Insert | `<S-Tab>` | Select previous completion item, then snippet backward, then fallback |
| Insert | `<C-y>` | Accept Supermaven suggestion when visible |

## Movement And Editing

| Mode | Key | Action |
|------|-----|--------|
| Normal | `j` | Move down, wrap-aware when no count is used |
| Normal | `k` | Move up, wrap-aware when no count is used |
| Normal | `n` | Next search result and center |
| Normal | `N` | Previous search result and center |
| Normal | `<C-d>` | Half page down and center |
| Normal | `<C-u>` | Half page up and center |
| Normal | `<Esc>` | Close LSP hover/signature float and clear search highlight |
| Terminal | `<Esc><Esc>` | Exit terminal mode |
| Visual | `<leader>P` | Paste without yanking replaced text |
| Normal | `J` | Join lines and keep cursor position |
| Normal | `<A-j>` | Move line down |
| Normal | `<A-k>` | Move line up |
| Visual | `<A-j>` | Move selection down |
| Visual | `<A-k>` | Move selection up |
| Visual | `<` | Indent left and reselect |
| Visual | `>` | Indent right and reselect |

## Windows And Buffers

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<C-h>` | Navigate left, tmux-aware |
| Normal | `<C-j>` | Navigate down, tmux-aware |
| Normal | `<C-k>` | Navigate up, tmux-aware |
| Normal | `<C-l>` | Navigate right, tmux-aware |
| Normal | `<leader>sv` | Split window vertically |
| Normal | `<leader>sh` | Split window horizontally |
| Normal | `<C-Up>` | Increase window height |
| Normal | `<C-Down>` | Decrease window height |
| Normal | `<C-Left>` | Decrease window width |
| Normal | `<C-Right>` | Increase window width |
| Normal | `<leader>bd` | Delete buffer |
| Normal | `<leader>bl` | Delete buffers to the left |
| Normal | `<leader>br` | Delete buffers to the right |
| Normal | `<leader>bo` | Delete other buffers |

## Flash

| Mode | Key | Action |
|------|-----|--------|
| Normal/Visual/Operator | `s` | Flash jump |
| Normal/Visual/Operator | `S` | Flash Treesitter |
| Operator | `r` | Remote Flash |
| Visual/Operator | `R` | Treesitter search |
| Normal | `<leader>tf` | Toggle Flash search |

## Find, Search, And Replace

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader><leader>` | Find files |
| Normal | `<leader>fo` | Recent files |
| Normal | `<leader>fg` | Live grep |
| Normal | `<leader>fc` | Grep current word |
| Normal | `<leader>fb` | Buffers picker |
| Normal | `<leader>fh` | Help picker |
| Normal | `<leader>fk` | Keymaps picker |
| Normal | `<leader>fx` | Buffer diagnostics picker |
| Normal | `<leader>fX` | Workspace diagnostics picker |
| Normal | `<leader>fn` | Notification history |
| Normal/Visual | `<leader>rr` | Search and replace in current file |
| Normal/Visual | `<leader>rR` | Search and replace in workspace |

## Toggles

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>tw` | Toggle line wrap |
| Normal | `<leader>td` | Toggle diagnostics |
| Normal | `<leader>tc` | Toggle system clipboard |
| Normal | `<leader>tg` | Toggle git signs |
| Normal | `<leader>tu` | Toggle undo tree |
| Normal | `<leader>tb` | Toggle inline git blame, off by default |
| Normal | `<leader>ts` | Toggle Supermaven |
| Normal | `<leader>tm` | Toggle render-markdown |
| Normal, LSP buffer | `<leader>th` | Toggle inlay hints, off by default |
| Normal, LSP buffer | `<leader>tC` | Toggle CodeLens, off by default |
| Normal, LSP buffer | `<leader>ti` | Toggle inline completion |

## Code, Diagnostics, And LSP

Global code mappings:

| Mode | Key | Action |
|------|-----|--------|
| Normal/Visual | `<leader>cf` | Format |
| Normal | `<leader>cL` | Lint |
| Normal | `<leader>cq` | Open diagnostic location list |
| Normal | `<leader>cl` | LSP config picker |
| Normal | `<leader>cR` | Rename file |

LSP buffer-local mappings:

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>lv` | Go to definition in vertical split |
| Normal | `<leader>cd` | Cursor diagnostics |
| Normal | `<leader>cD` | Line diagnostics |
| Normal | `<leader>ld` | Definitions picker |
| Normal | `<leader>lr` | References picker |
| Normal | `<leader>lt` | Type definitions picker |
| Normal | `<leader>ls` | Document symbols picker |
| Normal | `<leader>lw` | Workspace symbols picker |
| Normal | `<leader>li` | Implementations picker |
| Normal/Visual | `<leader>ca` | Code action |
| Normal | `<leader>cA` | Source action |
| Normal | `<leader>co` | Organize imports, then format |
| Normal | `<leader>cr` | Rename symbol |
| Normal | `<leader>lR` | Restart LSP |

Native LSP defaults intentionally left in use:

| Mode | Key | Action |
|------|-----|--------|
| Normal/Visual | `gra` | Code action |
| Normal | `grn` | Rename |
| Normal | `grr` | References |
| Normal | `gri` | Implementation |
| Normal | `grt` | Type definition |
| Normal/Visual | `grx` | Run CodeLens |
| Normal | `gO` | Document symbols |
| Normal | `K` | Hover |

Native diagnostic defaults intentionally left in use:

| Mode | Key | Action |
|------|-----|--------|
| Normal | `]d` | Next diagnostic |
| Normal | `[d` | Previous diagnostic |
| Normal | `]D` | Last diagnostic |
| Normal | `[D` | First diagnostic |

## Git And Hunks

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>gb` | Git blame current line |
| Normal | `<leader>gB` | Git browse |
| Normal | `<leader>gs` | Git status picker |
| Normal | `<leader>gd` | CodeDiff |
| Normal | `<leader>gg` | lazygit |
| Normal | `]h` | Next git hunk |
| Normal | `[h` | Previous git hunk |
| Normal | `]H` | Last git hunk |
| Normal | `[H` | First git hunk |
| Normal | `<leader>hs` | Stage hunk |
| Normal | `<leader>hr` | Reset hunk |
| Normal | `<leader>hp` | Preview hunk |

## Debugging

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>db` | Toggle breakpoint |
| Normal | `<leader>dB` | Clear breakpoints |
| Normal | `<leader>dc` | Continue |
| Normal | `<leader>ds` | Step over |
| Normal | `<leader>di` | Step into |
| Normal | `<leader>do` | Step out |
| Normal | `<leader>dt` | Toggle DAP UI |

## Rust And Cargo

Rust buffer-local mappings:

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>rn` | Rust runnables |
| Normal | `<leader>rd` | Rust debuggables |
| Normal | `<leader>re` | Expand macro |
| Normal | `<leader>ro` | Open external docs |
| Normal | `<leader>rj` | Move item down |
| Normal | `<leader>rk` | Move item up |

Cargo.toml buffer-local mappings:

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>rcu` | Update crate |
| Normal | `<leader>rcU` | Upgrade crate |
| Normal | `<leader>rca` | Update all crates |
| Normal | `<leader>rcA` | Upgrade all crates |
| Normal | `<leader>rcp` | Show crate popup |
| Normal | `<leader>rcr` | Reload crates |

## Markdown

| Mode | Key | Action |
|------|-----|--------|
| Normal, markdown buffer | `<leader>mp` | Toggle Markdown preview |
| Normal | `<leader>tm` | Toggle render-markdown |

## Sessions, Explorer, And Project Utilities

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>e` | Toggle Snacks explorer |
| Normal | `<leader>pa` | Copy full file path |
| Normal | `<leader>qq` | Quit all |
| Normal | `<leader>qs` | Restore session for current working directory |
| Normal | `<leader>qS` | Select session |
| Normal | `<leader>ql` | Restore last session |
| Normal | `<leader>qD` | Stop session save on exit |

## Filetype And Plugin-Local

| Context | Mode | Key | Action |
|---------|------|-----|--------|
| Quickfix/location list | Normal | `q` | Close quickfix/location window |
| grug-far buffer | Normal | `<localleader>r` | Replace |
| grug-far buffer | Normal | `<localleader>q` | Send results to quickfix |
| grug-far buffer | Normal | `<localleader>s` | Sync locations |
| grug-far buffer | Normal | `<localleader>l` | Sync line |
| grug-far buffer | Normal | `<localleader>c` | Close |
| grug-far buffer | Normal | `<localleader>t` | Open history |
| grug-far buffer | Normal | `<localleader>a` | Add to history |
| grug-far buffer | Normal | `<localleader>f` | Refresh |
| grug-far buffer | Normal | `<localleader>o` | Open location |
| grug-far buffer | Normal | `<localleader>b` | Abort |
| grug-far buffer | Normal | `<localleader>w` | Toggle command display |
| grug-far buffer | Normal | `<localleader>e` | Swap engine |
| grug-far buffer | Normal | `<localleader>i` | Preview location |
| grug-far buffer | Normal | `<localleader>x` | Swap replacement interpreter |
| grug-far buffer | Normal | `<localleader>j` | Apply next |
| grug-far buffer | Normal | `<localleader>k` | Apply previous |
| grug-far buffer | Normal | `<localleader>n` | Sync next |
| grug-far buffer | Normal | `<localleader>p` | Sync previous |
| grug-far buffer | Normal | `<localleader>v` | Sync file |

## Text Objects And Surround

Mini.surround mappings:

| Mode | Key | Action |
|------|-----|--------|
| Normal/Visual | `gsa` | Add surrounding |
| Normal | `gsd` | Delete surrounding |
| Normal | `gsf` | Find surrounding |
| Normal | `gsF` | Find surrounding to the left |
| Normal | `gsh` | Highlight surrounding |
| Normal | `gsr` | Replace surrounding |
| Normal | `gsn` | Update surrounding search line count |
