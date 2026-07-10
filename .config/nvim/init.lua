-- Bootstrap {{{
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local map = vim.keymap.set
local pack = vim.pack.add
local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })
-- }}}

-- Options {{{
vim.o.termguicolors = true
vim.o.number = true -- line number
vim.o.relativenumber = true -- relative line numbers
vim.o.cursorline = true -- highlight current line
vim.o.scrolloff = 10 -- keep 10 lines above/below cursor
vim.o.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.o.tabstop = 2 -- tabwidth
vim.o.shiftwidth = 2 -- indent width
vim.o.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
vim.o.expandtab = true -- use spaces instead of tabs
vim.o.smartindent = true -- smart auto-indent

vim.o.ignorecase = true -- case insensitive search
vim.o.smartcase = true -- case sensitive if uppercase in string

vim.o.signcolumn = "yes" -- always show a sign column
vim.o.colorcolumn = "80" -- show a column at 80 position chars
vim.o.showmatch = true -- highlights matching brackets
vim.o.laststatus = 3 -- use a single global statusline
vim.o.pumheight = 10 -- popup menu height
vim.o.pumblend = 10 -- popup menu transparency
vim.o.winborder = "rounded" -- rounded borders for floating windows

vim.o.writebackup = false -- do not write to a backup file
vim.o.swapfile = false -- do not create a swapfile
vim.o.undofile = true -- do create an undo file

vim.opt.iskeyword:append("-") -- include - in words
vim.o.mouse = "a" -- enable mouse support

vim.o.splitbelow = true -- horizontal splits go below
vim.o.splitright = true -- vertical splits go right

vim.o.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append("linematch:60") -- improve diff display

-- Set a useful terminal title so each pane is distinguishable (dir + file).
-- Tested with ghostty/wezterm; overrides the shell's title while nvim is running.
vim.o.title = true
vim.o.titlestring = "%{fnamemodify(getcwd(),':~')} - %t%(%m%)"
-- }}}

-- Core editing {{{
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
map("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Macros {{{
-- Map Q to start recording macros
map("n", "Q", "q", { desc = "Record macro" })
-- Disable the original q key
map("n", "q", "<Nop>", { desc = "Disable macro recording" })
-- }}}
-- }}}

-- Buffers {{{
map("n", "<leader>bd", "<cmd>bn|bd #<CR>", { desc = "Delete buffer keep split" })
local function close_other_buffers()
	local cur = vim.api.nvim_get_current_buf()
	local targets = vim.tbl_filter(function(b)
		return b ~= cur and vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b) and not vim.bo[b].modified
	end, vim.api.nvim_list_bufs())

	for _, b in ipairs(targets) do
		pcall(vim.api.nvim_buf_delete, b, {})
	end
	vim.notify(("Closed %d buffer(s), any unsaved will remain open"):format(#targets), vim.log.levels.INFO)
end
map("n", "<leader>bo", close_other_buffers, { desc = "Close other buffers" })
-- }}}

-- Clipboard {{{
local function notify_toggle(title, enabled)
	vim.notify(("%s %s"):format(title, enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

-- explicitly set clipboard to force follow osc52 spec and not local cli utility
vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		-- setting empty as most terminals ban paste operation and neovim hangs
		-- while waiting for terminal output. We anyways can use the terminal's
		-- paste shortcut instead of neovim's.
		["+"] = function() end,
		["*"] = function() end,
	},
}

map("n", "<leader>tc", function()
	local enabled = vim.list_contains(vim.opt.clipboard:get(), "unnamedplus")
	if enabled then
		vim.opt.clipboard:remove("unnamedplus")
	else
		vim.opt.clipboard:append("unnamedplus")
	end
	notify_toggle("System clipboard", not enabled)
end, { desc = "Toggle system clipboard" })

map("n", "<leader>tw", function()
	vim.wo.wrap = not vim.wo.wrap
	notify_toggle("Line wrap", vim.wo.wrap)
end, { desc = "Toggle line wrap" })
-- }}}

-- Pack {{{
-- install/update hooks {{{
-- Must be registered before pack() so PackChanged events are seen.
vim.api.nvim_create_autocmd("PackChanged", {
	group = group,
	desc = "Post-install hooks for plugins that need a build step",
	callback = function(ev)
		local spec = ev.data.spec
		local kind = ev.data.kind
		if not spec or (kind ~= "install" and kind ~= "update") then
			return
		end
		local function ensure_loaded()
			if not ev.data.active then
				vim.cmd.packadd(spec.name)
			end
		end
		-- fff.nvim ships a native binary; download/build it on install and update.
		if spec.name == "fff.nvim" then
			ensure_loaded()
			require("fff.download").download_or_build_binary()
		elseif spec.name == "nvim-treesitter" then
			ensure_loaded()
			vim.cmd.TSUpdate()
		end
	end,
})
-- }}}

-- plugin list {{{
pack({
	"https://github.com/shaunsingh/nord.nvim",
	"https://github.com/dmtrKovalenko/fff.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/conform.nvim",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/tpope/vim-fugitive",
	"https://github.com/dlyongemallo/diffview-plus.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
})
-- }}}
-- }}}

-- Theme {{{
-- Prefer soft backgrounds over reverse for Diff* (fugitive / diffview / mini overlay).
vim.g.nord_uniform_diff_background = true

local function apply_highlights()
	-- Nord palette accents used below.
	local nord1, nord2 = "#3B4252", "#434C5E"
	local green, yellow, red = "#A3BE8C", "#EBCB8B", "#BF616A" -- nord14/13/11
	-- Soft tinted backgrounds (nord polar night + accent).
	local add_bg, change_bg, delete_bg = "#3B4A3F", "#4A463B", "#4A3B3F"

	-- match nord's WinBar background so segments blend with the bar
	local winbar_bg = nord1
	vim.api.nvim_set_hl(0, "WinBar", { bg = winbar_bg, fg = "#D8DEE9" }) -- nord4 fg for filler/uncolored text
	vim.api.nvim_set_hl(0, "WinBarNC", { bg = winbar_bg, fg = "#4C566A" }) -- nord3 dim for non-current window
	vim.api.nvim_set_hl(0, "WinBarFile", { bg = winbar_bg, fg = "#88C0D0", bold = true }) -- nord8 cyan filename
	vim.api.nvim_set_hl(0, "WinBarMod", { bg = winbar_bg, fg = red, bold = true }) -- nord11 red [+]
	vim.api.nvim_set_hl(0, "WinBarFT", { bg = winbar_bg, fg = "#81A1C1" }) -- nord9 dim cyan filetype

	-- Built-in diff (also drives diffview + mini.diff overlay via links).
	vim.api.nvim_set_hl(0, "DiffAdd", { bg = add_bg })
	vim.api.nvim_set_hl(0, "DiffChange", { bg = change_bg })
	vim.api.nvim_set_hl(0, "DiffDelete", { fg = red, bg = delete_bg })
	vim.api.nvim_set_hl(0, "DiffText", { fg = yellow, bg = nord2, bold = true })

	-- Sign / status colors: mini.diff → Added/Changed/Removed; fugitive/diffview → diff*.
	vim.api.nvim_set_hl(0, "Added", { fg = green })
	vim.api.nvim_set_hl(0, "Changed", { fg = yellow })
	vim.api.nvim_set_hl(0, "Removed", { fg = red })
	vim.api.nvim_set_hl(0, "diffAdded", { fg = green })
	vim.api.nvim_set_hl(0, "diffChanged", { fg = yellow })
	vim.api.nvim_set_hl(0, "diffRemoved", { fg = red })
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = apply_highlights,
})
vim.cmd.colorscheme("nord")
-- }}}

-- UI chrome {{{
-- Inactive winbar {{{
-- Winbar: show only on INACTIVE normal-file windows
local winbar_str = "%#WinBarFile#%f%* %#WinBarMod#%m%*%=%#WinBarFT#%{&filetype}%*"

local function is_normal_file(buf)
	local bt = vim.bo[buf].buftype
	local fname = vim.api.nvim_buf_get_name(buf)
	return bt == "" and fname ~= ""
end

-- Window becoming active: hide winbar only for normal files (keep Oil/etc.)
vim.api.nvim_create_autocmd("WinEnter", {
	group = group,
	desc = "Hide winbar on the now-active normal-file window",
	callback = function()
		if is_normal_file(0) then
			vim.wo.winbar = nil
		end
	end,
})

-- Window becoming inactive: show winbar if it's a normal file buffer
vim.api.nvim_create_autocmd("WinLeave", {
	group = group,
	desc = "Show winbar on the now-inactive window (normal files only)",
	callback = function()
		if is_normal_file(0) then
			vim.wo.winbar = winbar_str
		end
	end,
})
-- }}}
-- }}}

-- General autocmds {{{
-- Cursor restore {{{
vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
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
-- }}}

-- Yank highlight {{{
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.hl.on_yank()
	end,
})
-- }}}

-- Quickfix {{{
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "qf",
	callback = function(args)
		vim.keymap.set("n", "q", "<cmd>close<CR>", {
			buffer = args.buf,
			silent = true,
			desc = "Close quickfix window",
		})
	end,
})
-- }}}

-- Gitcommit spell {{{
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "gitcommit",
	callback = function()
		vim.opt_local.spell = true
	end,
})
-- }}}
-- }}}

-- Plugins {{{
-- treesitter {{{
require("nvim-treesitter").install({
	"bash",
	"c",
	"css",
	"go",
	"html",
	"htmldjango",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"php",
	"python",
	"query",
	"rust",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
})

-- Askama templates live under templates/*.html (Jinja-like).
vim.filetype.add({
	pattern = {
		[".*/templates/.*%.html"] = "htmldjango",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Enable treesitter highlight + indent when a parser exists",
	callback = function(ev)
		if not pcall(vim.treesitter.start) then
			return
		end
		vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
-- }}}

-- autotag {{{
require("nvim-ts-autotag").setup({
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = false,
	},
	aliases = {
		htmldjango = "html",
	},
})
-- }}}

-- fff {{{
map("n", "<leader><SPACE>", function()
	require("fff").find_files()
end, { desc = "FFFind files" })
map("n", "<leader>/", function()
	require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
end, { desc = "Live fffuzy grep" })
-- }}}

-- grug-far {{{
require("grug-far").setup({})
-- }}}

-- oil {{{
local oil = require("oil")
-- Declare a global function to retrieve the current directory
function _G.get_oil_winbar()
	local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
	local dir = require("oil").get_current_dir(bufnr)
	if dir then
		return vim.fn.fnamemodify(dir, ":~")
	else
		-- If there is no current directory (e.g. over ssh), just show the buffer name
		return vim.api.nvim_buf_get_name(0)
	end
end

local detail = false
oil.setup({
	delete_to_trash = true,
	view_options = {
		show_hidden = true,
	},
	win_options = {
		winbar = "%!v:lua.get_oil_winbar()",
	},
	keymaps = {
		-- free up some as we use them for navigation already
		-- Keymap immediately next replaces the one above when false
		["gd"] = {
			callback = function()
				detail = not detail
				if detail then
					oil.set_columns({ "icon", "permissions", "size", "mtime" })
				else
					oil.set_columns({ "icon" })
				end
			end,
			desc = "Toggle file detail view",
		},
		-- Use grug-far to open search in dir
		["gs"] = {
			callback = function()
				-- get the current directory
				local prefills = { paths = oil.get_current_dir() }

				local grug_far = require("grug-far")
				-- instance check
				if not grug_far.has_instance("explorer") then
					grug_far.open({
						instanceName = "explorer",
						prefills = prefills,
						staticTitle = "Find and Replace from Explorer",
					})
				else
					grug_far.get_instance("explorer"):open()
					-- updating the prefills without clearing the search and other fields
					grug_far.get_instance("explorer"):update_input_values(prefills, false)
				end
			end,
			desc = "oil: Search in directory",
		},
	},
})
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
-- }}}

-- conform {{{
local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofumpt" },
		rust = { "rustfmt" },
		python = { "ruff_format" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		-- Use the "_" filetype to run formatters on filetypes that don't
		-- have other formatters configured.
		["_"] = { "trim_whitespace" },
	},
	-- This will also affect the default values for format_on_save/format_after_save
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = {
		timeout_ms = 500,
	},
})
map("n", "<leader>cf", function()
	conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
-- }}}

-- mini {{{
-- icons {{{
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()
-- }}}

-- snippets {{{
-- friendly-snippets via runtimepath. Default `**/html.json` also pulls Vue/Angular.
local gen_loader = require("mini.snippets").gen_loader
local from_lang = gen_loader.from_lang({
	lang_patterns = {
		html = { "html.json" },
		htmldjango = { "frameworks/djangohtml.json", "html.json" },
		blade = { "frameworks/blade/**/*.json" },
		javascriptreact = {
			"javascript/javascript.json",
			"javascript/react.json",
			"javascript/react-es7.json",
		},
		typescriptreact = {
			"javascript/typescript.json",
			"javascript/react-ts.json",
			"javascript/react-es7.json",
		},
	},
})
require("mini.snippets").setup({
	snippets = {
		-- Askama/htmldjango often report treesitter lang "html" at the cursor.
		function(context)
			if context and vim.bo[context.buf_id].filetype == "htmldjango" then
				context = vim.tbl_extend("force", {}, context, { lang = "htmldjango" })
			end
			return from_lang(context)
		end,
	},
	mappings = {
		expand = "<C-k>",
		jump_next = "<C-l>",
		jump_prev = "<C-h>",
		stop = "<C-c>",
	},
})
require("mini.snippets").start_lsp_server()
-- }}}

-- completion {{{
require("mini.completion").setup()
vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
-- }}}

-- pairs {{{
require("mini.pairs").setup()
-- Don't auto-close `{` in Jinja-like templates (typing `{%` / `{{`).
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "htmldjango", "jinja", "jinja2" },
	desc = "Disable curly brace pairing in template filetypes",
	callback = function(ev)
		vim.keymap.set("i", "{", "{", { buffer = ev.buf })
		vim.keymap.set("i", "}", "}", { buffer = ev.buf })
	end,
})

-- Accept selected completion item; otherwise use mini.pairs <CR>.
_G.cr_action = function()
	if vim.fn.complete_info().selected ~= -1 then
		return "\25" -- <C-y>
	end
	return MiniPairs.cr()
end
vim.keymap.set("i", "<CR>", "v:lua.cr_action()", { expr = true })
-- }}}

-- clue {{{
local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		{ mode = { "n", "x" }, keys = "<Leader>" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = { "n", "x" }, keys = "g" },
		{ mode = { "n", "x" }, keys = "'" },
		{ mode = { "n", "x" }, keys = "`" },
		{ mode = { "n", "x" }, keys = '"' },
		{ mode = { "i", "c" }, keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = { "n", "x" }, keys = "z" },
	},
	clues = {
		{ mode = "n", keys = "<Leader>b", desc = "+buffer" },
		{ mode = "n", keys = "<Leader>c", desc = "+code" },
		{ mode = "n", keys = "<Leader>g", desc = "+git" },
		{ mode = "n", keys = "<Leader>t", desc = "+toggle" },
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
		miniclue.gen_clues.square_brackets(),
	},
	window = { delay = 300 },
})
-- }}}

-- diff {{{
require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "│", change = "│", delete = "▁" },
	},
})
map("n", "<leader>go", function()
	MiniDiff.toggle_overlay()
end, { desc = "Toggle diff overlay" })
-- }}}

-- diffview {{{
require("diffview").setup({
	enhanced_diff_hl = true,
	use_icons = true,
})
-- }}}

-- sessions {{{
-- Per-cwd sessions under stdpath("data")/session (not in the project tree).
-- :SessionClear deletes it and skips save for this Neovim instance.
local session_save = true
require("mini.sessions").setup({
	autoread = false,
	autowrite = false,
	file = "",
	verbose = { read = false, write = false, delete = true },
})
local function session_name()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):gsub("/", "%%")
end
vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	nested = true,
	once = true,
	desc = "Resume cwd session if present",
	callback = function()
		-- Don't clobber an explicit file open (`nvim foo.txt`).
		if vim.fn.argc() > 0 then
			return
		end
		local name = session_name()
		if MiniSessions.detected[name] == nil then
			return
		end
		MiniSessions.read(name)
	end,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = group,
	desc = "Save cwd session on quit",
	callback = function()
		if not session_save then
			return
		end
		pcall(MiniSessions.write, session_name(), { force = true, verbose = false })
	end,
})
vim.api.nvim_create_user_command("Session", function()
	MiniSessions.read(session_name())
end, { desc = "Resume cwd session" })
vim.api.nvim_create_user_command("SessionClear", function()
	local name = session_name()
	pcall(MiniSessions.delete, name, { force = true })
	pcall(vim.fn.delete, vim.fs.joinpath(MiniSessions.config.directory, name))
	MiniSessions.detected[name] = nil
	vim.v.this_session = ""
	session_save = false
end, { desc = "Delete cwd session and skip save on quit" })
-- }}}

-- statusline {{{
require("mini.statusline").setup({ use_icons = true })
-- }}}
-- }}}
-- }}}

-- Diagnostics {{{
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
})
map("n", "<leader>cx", function()
	vim.diagnostic.setloclist({ open = true, title = "Diagnostics" })
end, { desc = "Open location list with buffer diagnostics" })
map("n", "<leader>cX", function()
	vim.diagnostic.setqflist({ open = true, title = "Workspace diagnostics" })
end, { desc = "Open quickfix list with all diagnostics" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show line diagnostic float" })
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
map("n", "<leader>td", function()
	local enabled = vim.diagnostic.is_enabled()
	vim.diagnostic.enable(not enabled)
	notify_toggle("Diagnostics", not enabled)
end, { desc = "Toggle diagnostics" })
-- }}}

-- LSP {{{
-- Esc / float clear {{{
local function close_lsp_floating_previews()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local ok, preview_buf = pcall(function()
			return vim.w[win].lsp_floating_bufnr
		end)
		if ok and preview_buf and vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end
end
map("n", "<Esc>", function()
	close_lsp_floating_previews()
	vim.cmd.nohlsearch()
end, { silent = true, desc = "Close LSP float and clear search highlight" })
-- }}}

-- LspAttach {{{
vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end

		-- Keep mini.clue triggers as the latest buffer-local maps.
		pcall(MiniClue.ensure_buf_triggers)

		map("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
		map("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
	end,
})
-- }}}

-- Servers {{{
-- nvim-lspconfig supplies default cmd/filetypes/root; only override here.
-- Mason installs binaries; mason-lspconfig auto-enables installed servers.

-- lua_ls {{{
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
			completion = { callSnippet = "Replace" },
			-- Formatting is owned by conform/stylua.
			format = { enable = false },
		},
	},
})
-- }}}

-- phpantom {{{
-- Not in Mason; enable only when the binary is on PATH.
if vim.fn.executable("phpantom_lsp") == 1 then
	vim.lsp.config("phpantom", {
		cmd = { "phpantom_lsp" },
		filetypes = { "php", "blade" },
		root_markers = { "artisan", "composer.json", ".git" },
	})
	vim.lsp.enable("phpantom")
end
-- }}}

-- mason {{{
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"rust_analyzer",
		"gopls",
		"ts_ls",
		"ty",
	},
	-- Enable installed servers via vim.lsp.enable() (nvim-lspconfig configs).
	automatic_enable = true,
})
-- }}}
-- }}}
-- }}}

-- vim: foldmethod=marker foldlevel=0
