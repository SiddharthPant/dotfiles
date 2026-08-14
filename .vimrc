vim9script

scriptencoding utf-8
set nocompatible
set encoding=utf-8

g:mapleader = ' '
g:maplocalleader = ','
g:vimrc_path = expand('<sfile>:p')

plug#begin()
Plug 'christoomey/vim-tmux-navigator'
plug#end()

# Appearance
set termguicolors
set background=dark
if !empty(globpath(&runtimepath, 'colors/catppuccin.vim'))
  colorscheme catppuccin
else
  colorscheme slate
endif
highlight Normal guibg=NONE ctermbg=NONE
highlight NormalNC guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE

set number
set relativenumber
set cursorline
set scrolloff=10
set sidescrolloff=10
set signcolumn=yes
set showmatch
set listchars=tab:^\ ,nbsp:¬,extends:»,precedes:«,trail:•
set laststatus=3
&statusline = '%f %m%=%y %{&fileencoding ==# "" ? &encoding : &fileencoding}'

# Editing
set backspace=indent,eol,start
set autoindent
set smartindent
set shiftround
set linebreak
set breakindent
set confirm
set autoread
set hidden
set mouse=a
set history=1000

set timeout
set timeoutlen=400
set ttimeoutlen=10
set updatetime=300

set tabstop=2
set shiftwidth=2
set softtabstop=-1
set expandtab
set smarttab
set iskeyword+=-

set splitbelow
set splitright

# Searching
set ignorecase
set smartcase
set incsearch
set hlsearch
set wrapscan

# Native Vim 9.2 insert completion.
set autocomplete
set autocompletedelay=100
set complete=.^5,w^5,b^5,u^5
set completeopt=menuone,noselect,popup,fuzzy
set pumopt=border:round,height:10,width:15,opacity:90
set shortmess+=c

inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

# Native Vim 9.2 command-line and search completion.
set wildmenu
set wildmode=noselect:lastused,full
set wildoptions=fuzzy,pum
set wildignorecase
set wildchar=<Tab>
set wildcharm=<C-@>
set wildignore=.git,.jj,node_modules,target,vendor,dist,*.o,*.swp

cnoremap <expr> <Up> wildmenumode() ? "\<C-E>\<Up>" : "\<Up>"
cnoremap <expr> <Down> wildmenumode() ? "\<C-E>\<Down>" : "\<Down>"

# Vim 9.2 diff alignment and inline highlighting.
set diffopt+=linematch:60
set diffopt+=algorithm:histogram

# Set a useful terminal title so each pane is distinguishable.
set title
set titlestring=%{fnamemodify(getcwd(),':~')}\ -\ %t%(%m%)

# Persistent undo and server-friendly recovery files.
for directory in ['~/.vim/backup', '~/.vim/swap', '~/.vim/undo']
  if !isdirectory(expand(directory))
    mkdir(expand(directory), 'p')
  endif
endfor

set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//
set undofile

# Shipped Vim 9.2 runtime packages, not third-party plugins.
g:hlyank_duration = 300
if !exists('#hlyank#TextYankPost')
  packadd hlyank
endif

g:osc52_disable_paste = true
if !exists('#VimOSC52Plugin#VimEnter')
  packadd osc52
endif
set clipmethod+=osc52

# Built-in netrw remains the dependency-free explorer.
g:netrw_banner = 0
g:netrw_liststyle = 3
g:netrw_winsize = 25

def Notify(message: string)
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

# Core editing
nnoremap <silent> <leader>qq <Cmd>qall<CR>
nnoremap <silent> <leader>rr <Cmd>execute 'source ' .. fnameescape(g:vimrc_path)<CR>
nnoremap <silent> <Esc> <Cmd>nohlsearch<CR>
tnoremap <Esc><Esc> <C-\><C-n>

nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap <leader>zj zcjzo
nnoremap <leader>zk zckzo

def JoinKeepCursor()
  var view = winsaveview()
  execute 'normal! ' .. v:count1 .. 'J'
  winrestview(view)
enddef

nnoremap <silent> J <ScriptCmd>JoinKeepCursor()<CR>

nnoremap <A-j> <Cmd>move .+1<CR>==
nnoremap <A-k> <Cmd>move .-2<CR>==
xnoremap <A-j> :move '>+1<CR>gv=gv
xnoremap <A-k> :move '<-2<CR>gv=gv
xnoremap < <gv
xnoremap > >gv

# Keep q safe while retaining macro recording on Q.
nnoremap Q q
nnoremap q <Nop>

def ToggleHiddenCharacters()
  &l:list = !&l:list
  Notify('Hidden characters ' .. (&l:list ? 'enabled' : 'disabled'))
enddef

var system_clipboard_copy = false

def ToggleSystemClipboardCopy()
  system_clipboard_copy = !system_clipboard_copy
  Notify('System clipboard copy ' .. (system_clipboard_copy ? 'enabled' : 'disabled'))
enddef

def CopyYankToSystemClipboard()
  if system_clipboard_copy && v:event.operator ==# 'y' && v:event.regname !=# '_'
    setreg('+', v:event.regcontents, v:event.regtype)
  endif
enddef

nnoremap <silent> <leader>th <ScriptCmd>ToggleHiddenCharacters()<CR>
nnoremap <silent> <leader>tc <ScriptCmd>ToggleSystemClipboardCopy()<CR>

def ListedBuffers(): list<dict<any>>
  return getbufinfo({buflisted: 1})
enddef

def DeleteCurrentBuffer()
  var current = bufnr()
  if &modified
    Notify('Buffer has unsaved changes')
    return
  endif

  if ListedBuffers()->len() == 1
    enew
  else
    bnext
  endif
  execute 'bdelete ' .. current
enddef

def DeleteOtherBuffers()
  var current = bufnr()
  var closed = 0
  var modified = 0

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

def FuzzyFind(arglead: string, _cmdline: string, _cursorpos: number): list<string>
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

def FuzzyBuffer(arglead: string, _cmdline: string, _cursorpos: number): list<string>
  var buffers = execute('buffers', 'silent!')->split("\n")
  var alternate = buffers->indexof((_, value) => value =~ '^\s*\d\+\s\+#')
  if alternate != -1
    [buffers[0], buffers[alternate]] = [buffers[alternate], buffers[0]]
  endif
  return empty(arglead) ? buffers : buffers->matchfuzzy(arglead)
enddef

def SelectCommandLineItem()
  selected_match = ''
  if getcmdline() !~ '^\s*\%(Grep\|Find\|Buffer\)\s'
    return
  endif

  var info = cmdcomplete_info()
  if empty(info) || !info.pum_visible || info.matches->empty()
    return
  endif

  selected_match = info.selected != -1 ? info.matches[info.selected] : info.matches[0]
  setcmdline(info.cmdline_orig)
enddef

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
nnoremap <leader>e <Cmd>Lexplore<CR>
nnoremap - <Cmd>Explore<CR>

def RepoDiffFold(): string
  var text = getline(v:lnum)
  if text =~ '^diff --git '
    return '>1'
  endif
  return '='
enddef

def FindRepository(directory: string): list<string>
  var current = directory->fnamemodify(':p')
  if current !=# '/'
    current = current->substitute('/\+$', '', '')
  endif

  while !empty(current)
    if isdirectory(current .. '/.jj')
      return ['jj', current]
    endif
    if isdirectory(current .. '/.git') || filereadable(current .. '/.git')
      return ['git', current]
    endif

    var parent = current->fnamemodify(':h')
    if parent ==# current
      break
    endif
    current = parent
  endwhile

  return []
enddef

def ShowRepoDiff(directory: string = '')
  var path = ''
  if !empty(directory)
    path = directory->expand()->fnamemodify(':p')
    if !isdirectory(path)
      Notify('Not a directory: ' .. directory)
      return
    endif
  endif

  var repository = FindRepository(empty(path) ? getcwd() : path)
  if empty(repository)
    Notify('No JJ or Git repository found for: ' .. (empty(path) ? getcwd() : path))
    return
  endif

  var command: list<string>
  if repository[0] ==# 'jj' && executable('jj')
    command = ['jj', '--repository', repository[1], 'diff', '--git', '--color=never']
  elseif repository[0] ==# 'git' && executable('git')
    command = ['git', '-C', repository[1], 'diff', '--no-ext-diff', '--no-color', 'HEAD']
  else
    Notify(repository[0] .. ' is not available')
    return
  endif

  if !empty(path)
    command->extend(['--', path])
  endif

  var output = systemlist(command)
  if v:shell_error != 0
    Notify(empty(output) ? 'Could not read repository diff' : output->join("\n"))
    return
  endif
  if empty(output)
    Notify('Repository has no changes')
    return
  endif

  tabnew
  execute 'file ' .. fnameescape('[Repo Diff]')
  setlocal buftype=nofile bufhidden=wipe noswapfile
  setline(1, output)
  setlocal filetype=diff nomodifiable readonly
  setlocal foldmethod=expr foldexpr=s:RepoDiffFold()
  setlocal foldenable foldlevel=0 foldcolumn=1
  nnoremap <silent> <buffer> q <Cmd>tabclose<CR>
enddef

command! -nargs=? -complete=dir RepoDiff ShowRepoDiff(<q-args>)
nnoremap <silent> <leader>gg <Cmd>RepoDiff<CR>

def ProjectRoot(filename: string): string
  var directory = fnamemodify(filename, ':p:h')

  while !empty(directory)
    for marker in ['.git', '.hg', '.svn']
      var candidate = directory .. '/' .. marker
      if isdirectory(candidate) || filereadable(candidate)
        return directory
      endif
    endfor

    var parent = fnamemodify(directory, ':h')
    if parent ==# directory
      break
    endif
    directory = parent
  endwhile

  return ''
enddef

def SetProjectRoot()
  var filename = expand('%:p')
  if empty(filename) || &buftype !=# ''
    return
  endif

  var root = ProjectRoot(filename)
  if !empty(root) && getcwd() !=# root
    execute 'silent cd ' .. fnameescape(root)
  endif
enddef

def RestoreCursorPosition()
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
  autocmd BufEnter * SetProjectRoot()
  autocmd FocusGained,BufEnter * checktime

  autocmd FileType help,qf nnoremap <buffer> q <Cmd>close<CR>
  autocmd FileType gitcommit setlocal spell
  autocmd FileType make setlocal noexpandtab
  autocmd FileType yaml,yml,json,lua,html,css,javascript,typescript setlocal tabstop=2 shiftwidth=2 softtabstop=-1 expandtab
augroup END

defcompile
