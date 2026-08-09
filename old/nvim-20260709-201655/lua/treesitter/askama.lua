local M = {}

local function register_parser()
	require("nvim-treesitter.parsers").askama = {
		install_info = {
			url = "https://github.com/lpnh/tree-sitter-askama",
			revision = "25bf80e9a719862bf020177525baee70e682749d",
			queries = "queries",
		},
	}
end

function M.setup()
	local group = vim.api.nvim_create_augroup("askama_parser", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "TSUpdate",
		desc = "Register the Askama parser",
		callback = register_parser,
	})
end

return M
