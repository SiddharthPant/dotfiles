require("github-theme").setup({
	options = {
		transparent = true,
		styles = {
			comments = "italic",
			conditionals = "italic",
			constants = "italic",
			keywords = "italic",
			types = "italic",
		},
	},
	groups = {
		all = {
			FloatBorder = { fg = "#8c959f" },
			WinSeparator = { fg = "#8c959f" },
			SnacksPickerBorder = { fg = "#8c959f" },
			SnacksPickerInputBorder = { fg = "#8c959f" },
			SnacksPickerListBorder = { fg = "#8c959f" },
			SnacksPickerPreviewBorder = { fg = "#8c959f" },
			SnacksNotifierBorder = { fg = "#8c959f" },
		},
	},
})

vim.cmd.colorscheme("github_light")
