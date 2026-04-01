local M = {}

function M.refresh(bufnr)
	local use_lsp_folds = #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/foldingRange" }) > 0
	for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
		vim.wo[winid].foldmethod = "expr"
		vim.wo[winid].foldexpr = use_lsp_folds and "v:lua.vim.lsp.foldexpr()" or "v:lua.vim.treesitter.foldexpr()"
		vim.wo[winid].foldtext = use_lsp_folds and "v:lua.vim.lsp.foldtext()" or ""
	end
	if vim.api.nvim_get_current_buf() == bufnr then
		vim.opt_local.foldexpr = use_lsp_folds and "v:lua.vim.lsp.foldexpr()" or "v:lua.vim.treesitter.foldexpr()"
		vim.opt_local.foldtext = use_lsp_folds and "v:lua.vim.lsp.foldtext()" or ""
	end
end

function M.setup()
	-- Folding: prefer LSP folding when available, otherwise use Treesitter
	vim.o.foldlevel = 99 -- start with all folds open
	vim.o.foldlevelstart = 99 -- keep folds open when a buffer is first shown
	vim.o.foldmethod = "expr"

	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = vim.api.nvim_create_augroup("Folding", { clear = true }),
		callback = function(args)
			M.refresh(args.buf)
		end,
	})
end

return M
