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

require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		{ path = "snacks.nvim", words = { "Snacks" } },
		{ path = "nvim-lspconfig", words = { "lspconfig", "vim%.lsp%.config" } },
	},
})

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
					layout = {
						position = "right", -- Show explorer on right
					},
				},
				win = {
					list = {
						keys = {
							["<C-l>"] = function()
								if vim.env.TMUX and vim.env.TMUX ~= "" then
									vim.system({ "tmux", "select-pane", "-R" })
								end
							end,
						},
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

require("flash").setup({})

require("grug-far").setup({
	keymaps = {
		replace = { n = ",r" },
		qflist = { n = ",q" },
		syncLocations = { n = ",s" },
		syncLine = { n = ",l" },
		close = { n = ",c" },
		historyOpen = { n = ",t" },
		historyAdd = { n = ",a" },
		refresh = { n = ",f" },
		openLocation = { n = ",o" },
		abort = { n = ",b" },
		toggleShowCommand = { n = ",w" },
		swapEngine = { n = ",e" },
		previewLocation = { n = ",i" },
		swapReplacementInterpreter = { n = ",x" },
		applyNext = { n = ",j" },
		applyPrev = { n = ",k" },
		syncNext = { n = ",n" },
		syncPrev = { n = ",p" },
		syncFile = { n = ",v" },
	},
})

require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
		untracked = { text = "▎" },
	},
	signs_staged = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
	signcolumn = true,
	current_line_blame = true,
})

require("codediff").setup({
	keymaps = {
		view = {
			next_hunk = "]h",
			prev_hunk = "[h",
		},
	},
})

vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_theme = "light"
local markdown_group = vim.api.nvim_create_augroup("MarkdownTools", { clear = true })

local function toggle_markdown_preview_theme()
	local bufnr = vim.api.nvim_get_current_buf()
	local theme = vim.g.mkdp_theme == "dark" and "light" or "dark"
	local was_open = vim.b.MarkdownPreviewToggleBool == 1

	vim.g.mkdp_theme = theme

	if was_open then
		vim.cmd("MarkdownPreviewStop")
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			vim.api.nvim_buf_call(bufnr, function()
				vim.cmd("MarkdownPreview")
			end)
		end, 100)
	end

	require("snacks").notify("Markdown preview theme: " .. theme, {
		title = "Markdown Preview",
		level = "info",
	})
end

vim.api.nvim_create_autocmd("FileType", {
	group = markdown_group,
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", {
			buffer = args.buf,
			desc = "Markdown Preview Toggle",
		})
		vim.keymap.set("n", "<leader>mt", toggle_markdown_preview_theme, {
			buffer = args.buf,
			desc = "Markdown Preview Theme Toggle",
		})
		vim.keymap.set("n", "<leader>mr", function()
			require("render-markdown").toggle()
		end, {
			buffer = args.buf,
			desc = "Markdown Render Toggle",
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

require("mini.pairs").setup()

require("mini.surround").setup({
	mappings = {
		add = "gsa", -- Add surrounding (e.g., gsaiw" surrounds word with ")
		delete = "gsd", -- Delete surrounding (e.g., gsd" removes surrounding ")
		find = "gsf", -- Find surrounding
		find_left = "gsF", -- Find surrounding (to the left)
		highlight = "gsh", -- Highlight surrounding
		replace = "gsr", -- Replace surrounding (e.g., gsr"' replaces " with ')
		update_n_lines = "gsn", -- Update `n_lines`
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
	},
	window = {
		config = { width = "auto", border = "rounded" },
		delay = 300,
	},
})

local statusline = require("mini.statusline")

local function compact(...)
	local ret = {}
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value and value ~= "" then
			table.insert(ret, value)
		end
	end
	return ret
end

local function section_path()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return "[No Name]"
	end
	return vim.fn.pathshorten(vim.fn.fnamemodify(name, ":~:."), 2)
end

local function section_file_state()
	local modified = vim.bo.modified and "[+]" or ""
	local readonly = (vim.bo.readonly or not vim.bo.modifiable) and "[RO]" or ""
	return modified, readonly
end

local function section_lsp()
	local names = {}
	local seen = {}
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if not seen[client.name] then
			seen[client.name] = true
			table.insert(names, client.name)
		end
	end
	table.sort(names)
	if #names == 0 then
		return ""
	end
	if #names == 1 then
		return "LSP " .. names[1]
	end
	return "LSP " .. names[1] .. "+" .. (#names - 1)
end

local function section_recording()
	local reg = vim.fn.reg_recording()
	return reg ~= "" and ("REC @" .. reg) or ""
end

local function section_progress()
	local line = vim.fn.line(".")
	local total = math.max(vim.fn.line("$"), 1)
	local column = vim.fn.virtcol(".")
	local width = math.max(vim.fn.virtcol("$") - 1, 0)
	local percent = math.floor((line / total) * 100)
	return string.format("%d/%d | %d/%d %d%%%%", column, width, line, total, percent)
end

local statusline_group = vim.api.nvim_create_augroup("StatuslineRefresh", { clear = true })
vim.api.nvim_create_autocmd("RecordingEnter", {
	group = statusline_group,
	callback = function()
		vim.cmd.redrawstatus()
	end,
})
vim.api.nvim_create_autocmd("RecordingLeave", {
	group = statusline_group,
	callback = function()
		vim.schedule(function()
			vim.cmd.redrawstatus()
		end)
	end,
})

statusline.setup({
	content = {
		active = function()
			local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
			local git = statusline.section_git({ trunc_width = 75 })
			local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
			local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
			local search = statusline.section_searchcount({ trunc_width = 75 })
			local modified, readonly = section_file_state()

			return statusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = compact(git, diagnostics) },
				"%<", -- Mark general truncate point
				{ hl = "MiniStatuslineFilename", strings = { section_path() } },
				{ hl = "MiniStatuslineFileinfo", strings = compact(modified, readonly) },
				"%=", -- End left alignment
				{ hl = "MiniStatuslineDevinfo", strings = compact(section_recording(), section_lsp()) },
				{ hl = "MiniStatuslineFileinfo", strings = compact(fileinfo) },
				{ hl = "MiniStatuslineFileinfo", strings = compact(search, section_progress()) },
			})
		end,
		inactive = function()
			return statusline.combine_groups({
				{ hl = "MiniStatuslineInactive", strings = { section_path() } },
				"%=",
				{ hl = "MiniStatuslineInactive", strings = compact(section_progress()) },
			})
		end,
	},
	use_icons = true,
})

require("bufferline").setup({
	options = {
		numbers = "buffer_id",
		indicator = { style = "underline" },
		separator_style = "thin",
		show_buffer_icons = false,
		show_close_icon = false,
		show_tab_indicators = false,
		modified_icon = "●",
		buffer_close_icon = "×",
		close_command = function(bufnr)
			require("snacks").bufdelete({ buf = bufnr })
		end,
		right_mouse_command = function(bufnr)
			require("snacks").bufdelete({ buf = bufnr })
		end,
		tab_size = 14,
		max_name_length = 14,
		truncate_names = true,
	},
})
