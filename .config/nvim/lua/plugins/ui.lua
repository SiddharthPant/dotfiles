require("mini.pairs").setup()

require("mini.surround").setup({
	mappings = {
		add = "gsa",
		delete = "gsd",
		find = "gsf",
		find_left = "gsF",
		highlight = "gsh",
		replace = "gsr",
		update_n_lines = "gsn",
		suffix_last = "l",
		suffix_next = "n",
	},
})

require("mini.clue").setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "n", keys = "<LocalLeader>" },
		{ mode = "x", keys = "<LocalLeader>" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "s" },
		{ mode = "x", keys = "s" },
		{ mode = "n", keys = "<CR>" },
	},
	clues = {
		require("mini.clue").gen_clues.builtin_completion(),
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.marks(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.windows(),
		require("mini.clue").gen_clues.z(),
	},
	window = {
		config = { width = "auto", border = "rounded" },
		delay = 300,
	},
})

require("mini.statusline").setup({
	use_icons = true,
})

vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_theme = "light"

local markdown_group = vim.api.nvim_create_augroup("MarkdownTools", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = markdown_group,
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", {
			buffer = args.buf,
			desc = "Markdown preview toggle",
		})
	end,
})

require("render-markdown").setup({
	file_types = { "markdown" },
	completions = {
		blink = { enabled = true },
	},
	code = {
		sign = false,
		width = "block",
		right_pad = 1,
	},
	heading = {
		sign = false,
		icons = {},
	},
	checkbox = {
		enabled = false,
	},
})

vim.keymap.set("n", "<leader>tm", function()
	require("render-markdown").toggle()
end, { desc = "Toggle render-markdown" })
