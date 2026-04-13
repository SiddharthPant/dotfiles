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
		javascript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		vue = { "prettierd", "prettier", stop_after_first = true },
		svelte = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		scss = { "prettierd", "prettier", stop_after_first = true },
		less = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		jsonc = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		lua = { "stylua" },
		python = { "ruff_format" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		go = { "gofumpt" },
		rust = { "rustfmt" },
	},
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
