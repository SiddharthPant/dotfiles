local M = {}

function M.setup()
	vim.o.foldlevel = 99 -- start with all folds open
	vim.o.foldlevelstart = 99 -- keep folds open when a buffer is first shown
	vim.o.foldmethod = "expr"
	vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	vim.o.foldtext = ""
end

return M
