require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	integrations = {
		blink_cmp = true,
		bufferline = true,
		gitsigns = true,
		mini = {
			enabled = true,
			indentscope_color = "",
		},
		native_lsp = {
			enabled = true,
		},
		snacks = {
			enabled = true,
		},
		treesitter = true,
	},
})

vim.cmd.colorscheme("catppuccin-mocha")
