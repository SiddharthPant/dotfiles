vim.o.termguicolors = true
vim.o.number = true -- line number
vim.o.relativenumber = true -- relative line numbers
vim.o.cursorline = true -- highlight current line
vim.o.wrap = false -- do not wrap lines by default
vim.o.scrolloff = 10 -- keep 10 lines above/below cursor
vim.o.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.o.tabstop = 2 -- tabwidth
vim.o.shiftwidth = 2 -- indent width
vim.o.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
vim.o.expandtab = true -- use spaces instead of tabs
vim.o.smartindent = true -- smart auto-indent

vim.o.ignorecase = true -- case insensitive search
vim.o.smartcase = true -- case sensitive if uppercase in string

vim.o.signcolumn = "yes" -- always show a sign column
vim.o.colorcolumn = "100" -- show a column at 100 position chars
vim.o.showmatch = true -- highlights matching brackets
vim.o.completeopt = "menuone,noselect,popup" -- completion options
vim.o.laststatus = 3 -- use a single global statusline
vim.o.showmode = false -- do not show the mode, instead have it in statusline
vim.o.pumheight = 10 -- popup menu height
vim.o.pumblend = 10 -- popup menu transparency
vim.o.winblend = 0 -- floating window transparency
vim.o.winborder = "rounded" -- rounded borders for floating windows
vim.o.conceallevel = 0 -- do not hide markup
vim.o.concealcursor = "" -- do not hide cursorline in markup
vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then -- create undodir if nonexistent
	vim.fn.mkdir(undodir, "p")
end

vim.o.writebackup = false -- do not write to a backup file
vim.o.swapfile = false -- do not create a swapfile
vim.o.undofile = true -- do create an undo file
vim.o.undodir = undodir -- set the undo directory
vim.o.updatetime = 300 -- faster completion
vim.o.timeoutlen = 500 -- timeout duration
vim.o.ttimeoutlen = 0 -- key code timeout
vim.o.autowrite = false -- do not auto-save

vim.opt.iskeyword:append("-") -- include - in words
-- vim.o.path:append("**") -- include subdirs in search
vim.o.mouse = "a" -- enable mouse support
-- vim.o.clipboard:append("unnamedplus") -- use system clipboard

vim.o.splitbelow = true -- horizontal splits go below
vim.o.splitright = true -- vertical splits go right

vim.o.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append("linematch:60") -- improve diff display

require("config.folds").setup()
