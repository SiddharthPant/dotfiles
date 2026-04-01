local function setup_treesitter()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})

	local ensure_installed = {
		"vim",
		"vimdoc",
		"rust",
		"c",
		"cpp",
		"go",
		"html",
		"css",
		"javascript",
		"json",
		"lua",
		"markdown",
		"python",
		"typescript",
		"vue",
		"svelte",
		"bash",
	}

	local config = require("nvim-treesitter.config")
	local already_installed = config.get_installed()
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
			table.insert(parsers_to_install, parser)
		end
	end

	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

setup_treesitter()

require("snacks").setup({
	bigfile = { enabled = true },
	bufdelete = { enabled = true },
	explorer = {
		enabled = true,
		replace_netrw = true,
	},
	git = { enabled = true },
	gitbrowse = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	notifier = { enabled = true },
	notify = { enabled = true },
	picker = {
		enabled = true,
		sources = {
			files = {
				hidden = true, -- Show hidden files in file picker
				ignored = false, -- Don't show gitignored files
			},
			explorer = {
				hidden = true, -- Show hidden files
				ignored = true, -- Show gitignored files
				layout = {
					preview = false,
					layout = {
						position = "right", -- Show explorer on right
					},
				},
			},
		},
	},
	quickfile = { enabled = true },
	scope = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
})

require("gitsigns").setup({
	signs = {
		add = { text = "\u{2590}" }, -- ▏
		change = { text = "\u{2590}" }, -- ▐
		delete = { text = "\u{2590}" }, -- ◦
		topdelete = { text = "\u{25e6}" }, -- ◦
		changedelete = { text = "\u{25cf}" }, -- ●
		untracked = { text = "\u{25cb}" }, -- ○
	},
	signcolumn = true,
	current_line_blame = false,
})

require("mini.surround").setup({
	mappings = {
		add = "sa", -- Add surrounding (e.g., saiw" surrounds word with ")
		delete = "sd", -- Delete surrounding (e.g., sd" removes surrounding ")
		find = "sf", -- Find surrounding
		find_left = "sF", -- Find surrounding (to the left)
		highlight = "sh", -- Highlight surrounding
		replace = "sr", -- Replace surrounding (e.g., sr"' replaces " with ')
		update_n_lines = "sn", -- Update `n_lines`
		suffix_last = "l", -- Suffix to search with "prev" method
		suffix_next = "n", -- Suffix to search with "next" method
	},
})

require("mini.clue").setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
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
		{ mode = "n", keys = "<CR>", desc = "Jump to 2 chars (jump2d)" },
	},
	window = {
		config = { width = "auto", border = "rounded" },
		delay = 300,
	},
})

require("mini.jump2d").setup({
	mappings = {
		start_jumping = "<CR>", -- Press Enter then type 2 chars to jump
	},
})

require("mini.statusline").setup({
	content = {
		active = function()
			local mode, mode_hl = require("mini.statusline").section_mode({ trunc_width = 120 })
			local git = require("mini.statusline").section_git({ trunc_width = 75 })
			local diagnostics = require("mini.statusline").section_diagnostics({ trunc_width = 75 })
			local filename = require("mini.statusline").section_filename({ trunc_width = 140 })
			local fileinfo = require("mini.statusline").section_fileinfo({ trunc_width = 120 })
			local location = require("mini.statusline").section_location({ trunc_width = 75 })
			local search = require("mini.statusline").section_searchcount({ trunc_width = 75 })

			return require("mini.statusline").combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
				"%<", -- Mark general truncate point
				{ hl = "MiniStatuslineFilename", strings = { filename } },
				"%=", -- End left alignment
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
				{ hl = mode_hl, strings = { search, location } },
			})
		end,
	},
	use_icons = true,
})

require("mini.tabline").setup({
	show_icons = false,
	tabpage_section = "right", -- Show tabpages on the right
})
