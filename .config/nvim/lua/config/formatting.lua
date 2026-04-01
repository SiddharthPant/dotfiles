vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({
		timeout_ms = 2000,
	})
end, { desc = "Code Format" })

require("conform").setup({
	default_format_opts = {
		lsp_format = "never",
	},
	notify_no_formatters = false,
	format_on_save = function(bufnr)
		if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(bufnr) == "" then
			return
		end
		return { timeout_ms = 2000 }
	end,
	formatters_by_ft = {
		javascript = { "oxfmt" },
		javascriptreact = { "oxfmt" },
		typescript = { "oxfmt" },
		typescriptreact = { "oxfmt" },
		vue = { "oxfmt" },
		svelte = { "oxfmt" },
		css = { "oxfmt" },
		scss = { "oxfmt" },
		less = { "oxfmt" },
		html = { "oxfmt" },
		json = { "oxfmt" },
		jsonc = { "oxfmt" },
		markdown = { "oxfmt" },
		lua = { "stylua" },
		python = { "ruff_format" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		go = { "gofumpt" },
	},
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
