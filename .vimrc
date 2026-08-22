vim9script

scriptencoding utf-8  # Decode this script itself as UTF-8.
set nocompatible  # Disable legacy Vi-compatible behavior.
set encoding=utf-8  # Use UTF-8 internally for text and buffers.

g:mapleader = ' '  # Use Space as the prefix for global custom mappings.
g:maplocalleader = ','  # Use comma as the prefix for buffer-local custom mappings.

plug#begin()
Plug 'christoomey/vim-tmux-navigator'
Plug 'will133/vim-dirdiff'
Plug 'tpope/vim-fugitive'
Plug 'luochen1990/rainbow'
plug#end()

g:rainbow_active = 1

# Appearance
set termguicolors # Enable 24-bit terminal colors.
set background=dark  # Tell color schemes to use their dark-background palette.
colorscheme novum  # Load Vim's built-in novum color scheme.
&t_SI = "\e[6 q"  # Ask the terminal for a vertical-bar cursor in Insert mode.
&t_EI = "\e[2 q"  # Ask the terminal for a block cursor after leaving Insert mode.

set number  # Show absolute line numbers.
set relativenumber  # Show relative line numbers away from the cursor line.
set cursorline  # Highlight the screen line containing the cursor.
set scrolloff=10  # Keep ten screen lines visible above and below the cursor when possible.
set sidescrolloff=10  # Keep ten columns visible to either side when scrolling horizontally.
set signcolumn=yes  # Always reserve the sign column so text does not shift when signs appear.
set showmatch  # Briefly highlight a matching bracket after inserting one.
set listchars=tab:^\ ,nbsp:¬,extends:»,precedes:«,trail:•  # Define how tabs, non-breaking spaces, overflow, and trailing spaces look with 'list'.
set laststatus=3  # Use one global status line instead of one per window.
&statusline = '%f %m%=%y %{&fileencoding ==# "" ? &encoding : &fileencoding}'  # Show file name and modified state on the left, then type and encoding on the right.

# Editing
set backspace=indent,eol,start  # Editing: Allow Backspace over autoindent, line breaks, and the point where Insert mode started.
set autoindent  # Copy the current line's indent when starting a new line.
set smartindent  # Add extra C-like indentation heuristics.
set shiftround  # Round indentation commands to a multiple of 'shiftwidth'.
set linebreak  # Wrap long lines at convenient character boundaries without changing the file.
set breakindent  # Preserve an appropriate visual indent on wrapped screen lines.
set confirm  # Ask for confirmation instead of failing when an operation would discard changes.
set autoread  # Reload files changed outside Vim when it is safe to do so.
set hidden  # Allow modified buffers to remain open in the background when switching buffers.
set mouse=a  # Enable mouse support in every mode.
set history=10000  # Retain up to 10,000 command and search history entries.

set timeout  # Enable timeouts for mappings and terminal key codes.
set timeoutlen=400  # Wait at most 400 ms for the rest of a mapped key sequence.
set ttimeoutlen=10  # Wait at most 10 ms for the rest of a terminal key code.
set updatetime=300  # Trigger swap writes and CursorHold events after 300 ms of inactivity.

set tabstop=2  # Display a literal tab as two columns wide.
set shiftwidth=2  # Indent and unindent by two columns.
set softtabstop=-1  # Make Insert-mode Tab and Backspace use the 'shiftwidth' value.
set expandtab  # Insert spaces instead of literal tab characters.
set smarttab  # At the start of a line, make Tab and Backspace follow indentation widths.
set iskeyword+=-  # Treat hyphens as part of words for motions, completion, and word searches.

set splitbelow  # Open horizontal splits below the current window.
set splitright  # Open vertical splits to the right of the current window.

set ignorecase  # Searching: Ignore letter case in searches by default.
set smartcase  # Make a search case-sensitive when its pattern contains an uppercase letter.
set incsearch  # Update matches while the search pattern is being typed.
set hlsearch  # Highlight all matches of the latest search.
set wrapscan  # Continue searches from the opposite end after reaching the file boundary.

# set autocomplete  # Start insert completion automatically; left disabled for manual completion.
set autocompletedelay=100  # Wait 100 ms before showing automatic insert completion.
set complete=.^5,w^5,b^5,u^5  # Complete from the current buffer first, then windows, loaded buffers, and unloaded buffers.
set completeopt=menu,noselect,popup,fuzzy  # Always show a fuzzy completion menu without preselecting an item; use popup details.
set pumopt=height:15 # Give the insert-completion popup a rounded border and fixed size/opacity limits.

inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

set wildmenu  # Display possible command-line completions.
set wildmode=noselect:lastused,full  # Begin with no selection, prioritize recently used matches, then cycle all matches.
set wildoptions=fuzzy,pum  # Use fuzzy matching and a popup menu for command-line completion.
set wildignorecase  # Match command-line completion candidates without regard to case.
set wildchar=<Tab>  # Use Tab to start and advance command-line completion.
set wildcharm=<C-@>  # Let mappings invoke command-line completion with Ctrl-@.
set wildignore=.git,.jj,node_modules,target,vendor,dist,*.o,*.swp  # Exclude VCS metadata, dependency/build directories, objects, and swap files.

cnoremap <expr> <Up> wildmenumode() ? "\<C-E>\<Up>" : "\<Up>"
cnoremap <expr> <Down> wildmenumode() ? "\<C-E>\<Down>" : "\<Down>"

set diffopt+=algorithm:histogram,vertical # Open diff splits vertically

# Persistent undo and server-friendly recovery files.
# Visit each directory used for backup, swap, and undo files.
for directory in ['~/.vim/backup', '~/.vim/swap', '~/.vim/undo']
  if !isdirectory(expand(directory))
    mkdir(expand(directory), 'p')
  endif
endfor

set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//
set undofile  # Save undo history to disk so it survives closing a file.

# Enable Default Vim feature packages
packadd! matchit # Make % jump over html tags etc.
packadd! editorconfig # Make vim respect editorconfig
packadd comment # Make gc comment a line
packadd nohlsearch # Auto remove highlighted searches after 'updatetime'(4-sec default) or switching to Insert mode

# Add and initialize Vim's optional hlyank package.
g:hlyank_invisual = v:true
g:hlput_enable = v:true
packadd hlyank  

# g:osc52_disable_paste = true  # Disable OSC 52 paste support while retaining its clipboard-copy support.
packadd osc52  # Add and initialize Vim's optional OSC 52 package.
set clipmethod+=osc52  # Add OSC 52 escape sequences as a clipboard transport.

g:netrw_banner = 0  # Built-in netrw remains the dependency-free explorer. Hide netrw's banner and command help.
g:netrw_liststyle = 3  # Display netrw files in a tree view.
g:netrw_winsize = 25 # Narrow down the netrw window

# Show a short top-right popup notification, falling back to message history.
def Notify(message: string)
  # Older Vim builds may not provide popup notifications.
  if exists('*popup_notification')
    popup_notification(message, {
      col: &columns,
      pos: 'topright',
      posinvert: false,
      time: 1800,
    })
  else
    echomsg message
  endif
enddef


nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap <leader>zj zcjzo
nnoremap <leader>zk zckzo

# Join the requested number of lines without moving the cursor on screen.
def JoinKeepCursor()
  # Save and restore the complete window view around the native Join operation.
  var view = winsaveview()
  execute 'normal! ' .. v:count1 .. 'J'
  winrestview(view)
enddef

nnoremap <silent> J <ScriptCmd>JoinKeepCursor()<CR>

xnoremap < <gv
xnoremap > >gv

# Keep q safe while retaining macro recording on Q.
nnoremap Q q
nnoremap q <Nop>

# Toggle display of the invisible characters configured by 'listchars'.
def ToggleHiddenCharacters()
  &l:list = !&l:list
  Notify('Hidden characters ' .. (&l:list ? 'enabled' : 'disabled'))
enddef

var system_clipboard_copy = false  # Track whether ordinary yanks should also be copied to the system clipboard.

# Toggle automatic copying of future yanks to the system clipboard.
def ToggleSystemClipboardCopy()
  system_clipboard_copy = !system_clipboard_copy
  Notify('System clipboard copy ' .. (system_clipboard_copy ? 'enabled' : 'disabled'))
enddef

# Copy a completed non-black-hole yank to the + register when the toggle is enabled.
def CopyYankToSystemClipboard()
  # Ignore deletes, changes, and deliberate writes to the black-hole register.
  if system_clipboard_copy && v:event.operator ==# 'y' && v:event.regname !=# '_'
    setreg('+', v:event.regcontents, v:event.regtype)
  endif
enddef

nnoremap <silent> <leader>th <ScriptCmd>ToggleHiddenCharacters()<CR>
nnoremap <silent> <leader>tc <ScriptCmd>ToggleSystemClipboardCopy()<CR>

# Return metadata for every listed buffer.
def ListedBuffers(): list<dict<any>>
  return getbufinfo({buflisted: 1})
enddef

# Delete the current buffer without closing its window or discarding changes.
def DeleteCurrentBuffer()
  var current = bufnr()
  # Refuse to delete a modified buffer.
  if &modified
    Notify('Buffer has unsaved changes')
    return
  endif

  # Put another buffer in the window before deleting the current one.
  if ListedBuffers()->len() == 1
    enew
  else
    bnext
  endif
  execute 'bdelete ' .. current
enddef

# Delete every other unmodified listed buffer and report what was kept.
def DeleteOtherBuffers()
  var current = bufnr()
  var closed = 0
  var modified = 0

  # Preserve the current buffer and any other buffer containing unsaved changes.
  for buffer in ListedBuffers()
    if buffer.bufnr == current
      continue
    endif
    if buffer.changed
      modified += 1
    else
      execute 'silent bdelete ' .. buffer.bufnr
      closed += 1
    endif
  endfor

  var message = printf('Closed %d other buffer%s', closed, closed == 1 ? '' : 's')
  if modified > 0
    message ..= printf('; kept %d modified buffer%s', modified, modified == 1 ? '' : 's')
  endif
  Notify(message)
enddef

nnoremap <silent> <leader>bd <ScriptCmd>DeleteCurrentBuffer()<CR>
nnoremap <silent> <leader>bo <ScriptCmd>DeleteOtherBuffers()<CR>

# Vim 9.2 fuzzy file, buffer, and live-grep completion.
var selected_match = null_string
var allfiles: list<string>

def GrepComplete(arglead: string, _cmdline: string, _cursorpos: number): list<string>
  if arglead->len() < 2
    return []
  endif

  if executable('rg')
    return systemlist('rg --vimgrep --smart-case --hidden --glob ''!.git'' -- ' .. shellescape(arglead))
  endif

  return systemlist('grep -REIHns --exclude-dir=.git --exclude-dir=.jj --exclude-dir=node_modules --exclude-dir=target --exclude="tags" --exclude="*.swp" -- ' .. shellescape(arglead) .. ' .')
enddef

def VisitGrepMatch(pattern: string)
  if (selected_match == null_string || empty(selected_match)) && !empty(pattern)
    var matches = GrepComplete(pattern, '', 0)
    if !empty(matches)
      selected_match = matches[0]
    endif
  endif

  if selected_match == null_string || empty(selected_match)
    Notify('No grep match selected')
    return
  endif

  var items = getqflist({lines: [selected_match]}).items
  if empty(items)
    Notify('Could not parse grep match')
    return
  endif

  var item = items[0]
  if !item->has_key('bufnr') || item.lnum <= 0
    Notify('Could not open grep match')
    return
  endif

  execute 'buffer ' .. item.bufnr
  cursor(item.lnum, max([item.col, 1]))
  setbufvar(item.bufnr, '&buflisted', 1)
  normal! zvzz
enddef

# Cache project files and fuzzy-filter them for :Find completion.
def FuzzyFind(arglead: string, _cmdline: string, _cursorpos: number): list<string>
  # Populate the cache once per command-line session, preferring fd over find.
  if allfiles == null_list
    var root = get(g:, 'fzfind_root', '.')
    if executable('fd')
      allfiles = systemlist('fd --color=never --hidden --type f --type l --exclude .git --exclude .jj --exclude node_modules --exclude target --exclude vendor --exclude dist . ' .. shellescape(root))
    else
      allfiles = systemlist('find ' .. shellescape(root) .. ' \( -path "*/.git" -o -path "*/.jj" -o -path "*/node_modules" -o -path "*/target" -o -path "*/vendor" -o -path "*/dist" \) -prune -o \( -type f -o -type l \) -print')
    endif
  endif
  return empty(arglead) ? allfiles : allfiles->matchfuzzy(arglead)
enddef

# Return listed buffers, fuzzy-filtered, with the alternate buffer promoted first.
def FuzzyBuffer(arglead: string, _cmdline: string, _cursorpos: number): list<string>
  var buffers = execute('buffers', 'silent!')->split("\n")
  var alternate = buffers->indexof((_, value) => value =~ '^\s*\d\+\s\+#')
  if alternate != -1
    [buffers[0], buffers[alternate]] = [buffers[alternate], buffers[0]]
  endif
  return empty(arglead) ? buffers : buffers->matchfuzzy(arglead)
enddef

# Save the popup selection before Vim tears down a custom command line.
def SelectCommandLineItem()
  selected_match = ''
  if getcmdline() !~ '^\s*\%(Grep\|Find\|Buffer\)\s'
    return
  endif

  var info = cmdcomplete_info()
  if empty(info) || !info.pum_visible || info.matches->empty()
    return
  endif

  # Use the highlighted item, or the first candidate when nothing is highlighted.
  selected_match = info.selected != -1 ? info.matches[info.selected] : info.matches[0]
  setcmdline(info.cmdline_orig)
enddef

# Edit the selected :Find candidate, falling back to the first fuzzy match.
def OpenSelectedFile(pattern: string)
  if empty(selected_match) && !empty(pattern)
    var matches = FuzzyFind(pattern, '', 0)
    if !empty(matches)
      selected_match = matches[0]
    endif
  endif

  if !empty(selected_match)
    execute 'edit ' .. fnameescape(selected_match)
  endif
enddef

# Switch to the selected :Buffer candidate, falling back to the first fuzzy match.
def OpenSelectedBuffer(pattern: string)
  if empty(selected_match) && !empty(pattern)
    var matches = FuzzyBuffer(pattern, '', 0)
    if !empty(matches)
      selected_match = matches[0]
    endif
  endif

  if empty(selected_match)
    return
  endif
  # Extract the buffer number from the formatted :buffers line.
  var number = selected_match->matchstr('^\s*\zs\d\+')
  if !empty(number)
    execute 'buffer ' .. number
  endif
enddef

command! -nargs=+ -complete=customlist,GrepComplete Grep VisitGrepMatch(<q-args>)
command! -nargs=* -complete=customlist,FuzzyFind Find OpenSelectedFile(<q-args>)
command! -nargs=* -complete=customlist,FuzzyBuffer Buffer OpenSelectedBuffer(<q-args>)

nnoremap <leader><Space> :Find <C-@>
nnoremap <leader><BS> :Buffer <C-@>
nnoremap <leader>/ :Grep <C-@>
nnoremap <leader>? :Grep <C-R>=expand('<cword>')<CR><C-@>
nnoremap <leader>fh :help <C-@>

# Restore the cursor to the last position saved for a reopened ordinary file.
def RestoreCursorPosition()
  # Diff and VCS/editing utility buffers should always use their deliberate initial position.
  if &diff || index(['gitcommit', 'gitrebase', 'xxd'], &filetype) != -1
    return
  endif

  var position = getpos("'\"")
  if position[1] > 0 && position[1] <= line('$')
    setpos('.', position)
  endif
enddef

augroup UserConfig
  autocmd!
  autocmd CmdlineChanged :,/,? wildtrigger()
  autocmd CmdlineEnter : allfiles = null_list
  autocmd CmdlineLeavePre : SelectCommandLineItem()
  autocmd TextYankPost * CopyYankToSystemClipboard()

  autocmd BufReadPost * RestoreCursorPosition()
  autocmd FocusGained,BufEnter * checktime

  autocmd FileType help,qf nnoremap <buffer> q <Cmd>close<CR>
  autocmd FileType gitcommit setlocal spell
  autocmd FileType make setlocal noexpandtab
  autocmd FileType yaml,yml,json,lua,html,css,javascript,typescript setlocal tabstop=2 shiftwidth=2 softtabstop=-1 expandtab
augroup END

defcompile
