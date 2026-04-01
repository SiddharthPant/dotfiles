-- ============================================================================
-- OPTIONS
-- ============================================================================
vim.o.termguicolors = true
vim.o.number = true -- line number
vim.o.relativenumber = true -- relative line numbers
vim.o.cursorline = true -- highlight current line
vim.o.wrap = false -- do not wrap lines by default
vim.o.scrolloff = 10 -- keep 10 lines above/below cursor
vim.o.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.o.tabstop = 2 -- tabwidth
vim.o.shiftwidth = 2 -- indent width
vim.o.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
vim.o.expandtab = true -- use spaces instead of tabs
vim.o.smartindent = true -- smart auto-indent
vim.o.autoindent = true -- copy indent from current line

vim.o.ignorecase = true -- case insensitive search
vim.o.smartcase = true -- case sensitive if uppercase in string
vim.o.hlsearch = true -- highlight search matches
vim.o.incsearch = true -- show matches as you type

vim.o.signcolumn = "yes" -- always show a sign column
vim.o.colorcolumn = "100" -- show a column at 100 position chars
vim.o.showmatch = true -- highlights matching brackets
vim.o.cmdheight = 1 -- single line command line
vim.o.completeopt = "menuone,noinsert,noselect" -- completion options
vim.o.showmode = false -- do not show the mode, instead have it in statusline
vim.o.pumheight = 10 -- popup menu height
vim.o.pumblend = 10 -- popup menu transparency
vim.o.winblend = 0 -- floating window transparency
vim.o.conceallevel = 0 -- do not hide markup
vim.o.concealcursor = "" -- do not hide cursorline in markup
vim.o.synmaxcol = 300 -- syntax highlighting limit
vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

local undodir = vim.fn.expand("~/.vim/undodir")
if
	vim.fn.isdirectory(undodir) == 0 -- create undodir if nonexistent
then
	vim.fn.mkdir(undodir, "p")
end

vim.o.backup = false -- do not create a backup file
vim.o.writebackup = false -- do not write to a backup file
vim.o.swapfile = false -- do not create a swapfile
vim.o.undofile = true -- do create an undo file
vim.o.undodir = undodir -- set the undo directory
vim.o.updatetime = 300 -- faster completion
vim.o.timeoutlen = 500 -- timeout duration
vim.o.ttimeoutlen = 0 -- key code timeout
vim.o.autoread = true -- auto-reload changes if outside of neovim
vim.o.autowrite = false -- do not auto-save

vim.o.hidden = true -- allow hidden buffers
vim.o.errorbells = false -- no error sounds
vim.o.backspace = "indent,eol,start" -- better backspace behaviour
vim.opt.iskeyword:append("-") -- include - in words
-- vim.o.path:append("**") -- include subdirs in search
vim.o.selection = "inclusive" -- include last char in selection
vim.o.mouse = "a" -- enable mouse support
-- vim.o.clipboard:append("unnamedplus") -- use system clipboard
vim.o.encoding = "utf-8" -- set encoding

-- Folding: Only enable for reasonably sized files (performance optimization)
vim.o.foldlevel = 99 -- start with all folds open
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	group = vim.api.nvim_create_augroup("LazyFolding", { clear = true }),
	callback = function(args)
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if line_count < 5000 then -- Only enable folding for files under 5000 lines
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end
	end,
})

vim.o.splitbelow = true -- horizontal splits go below
vim.o.splitright = true -- vertical splits go right

vim.o.wildmenu = true -- tab completion
vim.o.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append("linematch:60") -- improve diff display
vim.o.redrawtime = 10000 -- increase neovim redraw tolerance
vim.o.maxmempattern = 20000 -- increase max memory

-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

-- better movement in wrapped text
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("n", "<leader>pa", function() -- show file path
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- Yank to system clipboard (visual and normal mode)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })

-- Delete to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", '"+d', { desc = "Delete to system clipboard" })
vim.keymap.set("n", "<leader>D", '"+D', { desc = "Delete line to system clipboard" })

-- Change to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>c", '"+c', { desc = "Change to system clipboard" })
vim.keymap.set("n", "<leader>C", '"+C', { desc = "Change line to system clipboard" })

-- Note: <leader>x is intentionally NOT mapped - uses normal register

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Format on save using conform.nvim (modern approach)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.lua",
		"*.py",
		"*.go",
		"*.js",
		"*.jsx",
		"*.ts",
		"*.tsx",
		"*.json",
		"*.jsonc",
		"*.css",
		"*.scss",
		"*.less",
		"*.html",
		"*.vue",
		"*.svelte",
		"*.sh",
		"*.bash",
		"*.zsh",
		"*.c",
		"*.cpp",
		"*.h",
		"*.hpp",
		"*.md",
		"*.mdx",
	},
	callback = function(args)
		-- avoid formatting non-file buffers (helps prevent weird write prompts)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		if not vim.bo[args.buf].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(args.buf) == "" then
			return
		end

		-- Use conform.nvim for formatting
		require("conform").format({
			bufnr = args.buf,
			timeout_ms = 2000,
			lsp_fallback = false, -- Don't fall back to LSP formatting
		})
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})
-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================
vim.pack.add({
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/folke/snacks.nvim",
	"https://www.github.com/echasnovski/mini.nvim", -- Only for surround + clue
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	-- Language Server Protocols (Native - no mason)
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	-- Advanced diff view
	"https://github.com/esmuellert/codediff.nvim",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end
packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("snacks.nvim")
packadd("mini.nvim") -- Only loading surround + clue + jump2d
packadd("codediff.nvim")
-- LSP (Native - no mason)
packadd("nvim-lspconfig")
-- Formatting and Linting (Modern: conform + nvim-lint)
packadd("conform.nvim")
packadd("nvim-lint")
packadd("blink.cmp")

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

local setup_treesitter = function()
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

-- ============================================================================
-- SNACKS.NVIM (Modern replacement for mini.nvim, nvim-tree, fzf-lua)
-- ============================================================================
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
				ignored = false, -- Don't show gitignored files
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

-- Snacks Explorer (replaces nvim-tree)
vim.keymap.set("n", "<leader>e", function()
	require("snacks").explorer()
end, { desc = "Toggle Explorer" })

-- Snacks Picker (replaces fzf-lua)
vim.keymap.set("n", "<leader>ff", function()
	require("snacks").picker.files()
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function()
	require("snacks").picker.grep()
end, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", function()
	require("snacks").picker.buffers()
end, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	require("snacks").picker.help()
end, { desc = "Find Help" })
vim.keymap.set("n", "<leader>fx", function()
	require("snacks").picker.diagnostics_buffer()
end, { desc = "Find Diagnostics (Buffer)" })
vim.keymap.set("n", "<leader>fX", function()
	require("snacks").picker.diagnostics()
end, { desc = "Find Diagnostics (Workspace)" })

-- Snacks Git
vim.keymap.set("n", "<leader>gb", function()
	require("snacks").git.blame_line()
end, { desc = "Git Blame Line" })
vim.keymap.set("n", "<leader>gB", function()
	require("snacks").gitbrowse()
end, { desc = "Git Browse" })

-- Snacks Buffer Delete (replaces mini.bufremove)
vim.keymap.set("n", "<leader>bd", function()
	require("snacks").bufdelete()
end, { desc = "Delete Buffer" })

-- Snacks Notifications
vim.keymap.set("n", "<leader>fn", function()
	require("snacks").notifier.show_history()
end, { desc = "Show Notifications" })

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

-- Note: LSP servers should be installed manually via your package manager
-- Example: npm install -g typescript-language-server pyright bash-language-server
-- Example: brew install lua-language-server gopls clangd

-- ============================================================================
-- MINI.NVIM - Only surround + clue + jump2d (no other modules)
-- ============================================================================
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
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },
		-- g key
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		-- s key (for surround)
		{ mode = "n", keys = "s" },
		{ mode = "x", keys = "s" },
		-- Enter key (for jump2d)
		{ mode = "n", keys = "<CR>" },
	},
	clues = {
		-- Enhance this by adding descriptions for <Leader> mappings
		require("mini.clue").gen_clues.builtin_completion(),
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.marks(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.windows(),
		require("mini.clue").gen_clues.z(),
		-- Custom clue for jump2d
		{ mode = "n", keys = "<CR>", desc = "Jump to 2 chars (jump2d)" },
	},
	window = {
		-- Show clues in a floating window
		config = { width = "auto", border = "rounded" },
		delay = 300, -- ms before showing
	},
})

-- mini.jump2d - 2-character jumping (sneak-style, not flash-style)
require("mini.jump2d").setup({
	mappings = {
		start_jumping = "<CR>", -- Press Enter then type 2 chars to jump
	},
})

vim.keymap.set("n", "]h", function()
	require("gitsigns").next_hunk()
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	require("gitsigns").prev_hunk()
end, { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })
vim.keymap.set("n", "<leader>hB", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })
vim.keymap.set("n", "<leader>hd", function()
	-- Open diff in new tab
	vim.cmd("tab split")
	require("gitsigns").diffthis()
end, { desc = "Diff this (new tab)" })
-- Show all changed files with diff preview
vim.keymap.set("n", "<leader>gs", function()
	require("snacks").picker.git_status()
end, { desc = "Git status (all files with diff)" })
-- Open codediff (VSCode-style diff view)
vim.keymap.set("n", "<leader>gv", ":CodeDiff<cr>", { desc = "Git diff view (codediff)" })

-- ============================================================================
-- LSP, Linting, Formatting & Completion
-- ============================================================================
local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "<leader>gd", function()
		require("snacks").picker.lsp_definitions()
	end, opts)

	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)

	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts)
	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)

	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	-- LSP Pickers (using snacks.nvim instead of fzf-lua)
	vim.keymap.set("n", "<leader>fd", function()
		require("snacks").picker.lsp_definitions()
	end, opts)
	vim.keymap.set("n", "<leader>fr", function()
		require("snacks").picker.lsp_references()
	end, opts)
	vim.keymap.set("n", "<leader>ft", function()
		require("snacks").picker.lsp_type_definitions()
	end, opts)
	vim.keymap.set("n", "<leader>fs", function()
		require("snacks").picker.lsp_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fw", function()
		require("snacks").picker.lsp_workspace_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fi", function()
		require("snacks").picker.lsp_implementations()
	end, opts)

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				require("conform").format({ bufnr = bufnr, timeout_ms = 2000 })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- ============================================================================
-- FORMATTING & LINTING KEYMAPS (conform.nvim + nvim-lint)
-- ============================================================================
-- Manual format (using <leader>cf to avoid collision with <leader>ff for fzf)
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({
		timeout_ms = 2000,
		lsp_fallback = false,
	})
end, { desc = "Code Format (conform.nvim)" })

-- Manual lint (Code Lint)
vim.keymap.set("n", "<leader>cl", function()
	require("lint").try_lint()
end, { desc = "Code Lint (nvim-lint)" })

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	snippets = {
		-- Use native Neovim 0.10+ snippets (no LuaSnip needed)
		expand = function(snippet)
			vim.snippet.expand(snippet)
		end,
		active = function(filter)
			return vim.snippet.active(filter)
		end,
		jump = function(direction)
			vim.snippet.jump(direction)
		end,
	},

	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})
vim.lsp.config("pyright", {})
vim.lsp.config("bashls", {})
vim.lsp.config("ts_ls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {})

-- ============================================================================
-- FORMATTING (conform.nvim) - Modern approach
-- ============================================================================
require("conform").setup({
	formatters_by_ft = {
		-- JavaScript/TypeScript - using oxfmt
		javascript = { "oxfmt" },
		javascriptreact = { "oxfmt" },
		typescript = { "oxfmt" },
		typescriptreact = { "oxfmt" },
		vue = { "oxfmt" },
		svelte = { "oxfmt" },
		-- Other web formats
		css = { "oxfmt" },
		scss = { "oxfmt" },
		less = { "oxfmt" },
		html = { "oxfmt" },
		json = { "oxfmt" },
		jsonc = { "oxfmt" },
		markdown = { "oxfmt" },
		-- Lua
		lua = { "stylua" },
		-- Python
		python = { "ruff_format" },
		-- Shell
		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
		-- C/C++
		c = { "clang_format" },
		cpp = { "clang_format" },
		-- Go
		go = { "gofumpt" },
	},
	formatters = {
		oxfmt = {
			-- Format via stdin - outputs to stdout (no --write flag needed)
			command = "oxfmt",
			args = { "--stdin-filepath", "$FILENAME" },
			stdin = true,
		},
	},
	format_on_save = false, -- We'll use our own autocmd for more control
})

-- ============================================================================
-- LINTING (nvim-lint) - Modern approach
-- ============================================================================
local lint = require("lint")

lint.linters_by_ft = {
	-- JavaScript/TypeScript - using oxlint
	javascript = { "oxlint" },
	javascriptreact = { "oxlint" },
	typescript = { "oxlint" },
	typescriptreact = { "oxlint" },
	vue = { "oxlint" },
	svelte = { "oxlint" },
	-- Other formats oxlint supports
	json = { "oxlint" },
	jsonc = { "oxlint" },
	-- Lua
	lua = { "luacheck" },
	-- Python
	python = { "ruff" },
	-- Shell
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	zsh = { "shellcheck" },
	-- C/C++
	c = { "cpplint" },
	cpp = { "cpplint" },
	-- Go
	go = { "golangcilint" },
}

-- Run linting on save
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		lint.try_lint()
	end,
})

-- ============================================================================
-- LSP SERVERS (Native - no mason, no efm)
-- ============================================================================
vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"ts_ls",
	"gopls",
	"clangd",
})
