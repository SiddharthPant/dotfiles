local mini_pairs = require("mini.pairs")

mini_pairs.setup({
	mappings = {
		["<"] = { action = "open", pair = "<>", neigh_pattern = "^[^%s\\]" },
		[">"] = { action = "close", pair = "<>", neigh_pattern = "^[^\\]" },
	},
})

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

local function notify_toggle(title, enabled)
	require("snacks").notify(("%s %s"):format(title, enabled and "enabled" or "disabled"), {
		title = title,
		level = "info",
	})
end

vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_theme = "light"

local markdown_group = vim.api.nvim_create_augroup("MarkdownTools", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = markdown_group,
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("n", "<leader>mp", function()
			vim.cmd.MarkdownPreviewToggle()
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(args.buf) then
					notify_toggle("Markdown preview", vim.b[args.buf].MarkdownPreviewToggleBool == 1)
				end
			end)
		end, {
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
	local render_markdown = require("render-markdown")
	render_markdown.toggle()
	notify_toggle("Render markdown", render_markdown.get())
end, { desc = "Toggle render-markdown" })
