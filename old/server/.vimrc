set nocompatible
scriptencoding utf-8
set encoding=utf-8

set termguicolors
filetype plugin indent on
syntax on
colorscheme habamax
" Make bg transparent
highlight Normal guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE

" UI
set number
set relativenumber
set cursorline
set showcmd
set ruler
set laststatus=2
set wildmenu
set wildmode=longest:full,full
set wildoptions=pum
set hidden
set mouse=a
set title
set splitbelow
set splitright
set scrolloff=5
set sidescrolloff=8
set signcolumn=yes
set colorcolumn=100

" Searching
set ignorecase
set smartcase
set incsearch
set hlsearch
set wrapscan

" Editing
set backspace=indent,eol,start
set autoindent
set smartindent
set shiftround
set linebreak
set breakindent
set history=1000
set confirm
set autoread

" Tabs / indentation
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab

" Completion
set completeopt=menuone,noinsert,noselect
set shortmess+=c

" Timing
set timeout
set timeoutlen=400
set ttimeoutlen=10
set updatetime=300

" Persistent undo + safer temp files
if !isdirectory(expand('~/.vim/backup'))
  call mkdir(expand('~/.vim/backup'), 'p')
endif
if !isdirectory(expand('~/.vim/swap'))
  call mkdir(expand('~/.vim/swap'), 'p')
endif
if !isdirectory(expand('~/.vim/undo'))
  call mkdir(expand('~/.vim/undo'), 'p')
endif

set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//
set undofile

" Netrw tweaks (built-in file explorer)
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25

" Leader
let mapleader = " "

" Useful mappings
nnoremap <Esc><Esc> :nohlsearch<CR>
nnoremap <leader>e :Lexplore<CR>
nnoremap Y y$
nnoremap Q <nop>
tnoremap <Esc> <C-\><C-n>
" Only enable 'q' to close in Help and Quickfix windows
autocmd FileType help,qf nnoremap <buffer> q :close<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Filetype-specific overrides
augroup my_vimrc
  autocmd!
  " Return to last cursor position
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   execute "normal! g`\"" |
        \ endif

  " Reload file changed outside Vim
  autocmd FocusGained,BufEnter * checktime

  " Makefiles must use tabs
  autocmd FileType make setlocal noexpandtab

  " Common 2-space formats
  autocmd FileType yaml,yml,json,lua,html,css,javascript,typescript
        \ setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
augroup END
