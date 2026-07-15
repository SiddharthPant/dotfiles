-- Bootstrap {{{
vim.loader.enable()
require("vim._core.ui2").enable({
	enable = true,
	msg = {
		target = "cmd",
		pager = { height = 0.5 },
		dialog = { height = 0.5 },
		cmd = { height = 0.5 },
		msg = { height = 0.5, timeout = 4500 },
	},
})

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local map = vim.keymap.set
local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })
-- }}}

-- Options {{{
vim.o.number = true -- line number
vim.o.relativenumber = true -- relative line numbers
vim.o.cursorline = true -- highlight current line
vim.o.scrolloff = 10 -- keep 10 lines above/below cursor
vim.o.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.o.tabstop = 2 -- tabwidth
vim.o.shiftwidth = 2 -- indent width
vim.o.softtabstop = -1 -- soft tab stop not tabs on tab/backspace
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
vim.o.splitbelow = true -- horizontal splits go below
vim.o.splitright = true -- vertical splits go right

vim.o.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append("linematch:60") -- improve diff display
vim.opt.sessionoptions:append("localoptions") -- preserve buffer-local options in sessions

-- Set a useful terminal title so each pane is distinguishable (dir + file).
-- Tested with ghostty/wezterm; overrides the shell's title while nvim is running.
vim.o.title = true
vim.o.titlestring = "%{fnamemodify(getcwd(),':~')} - %t%(%m%)"
-- }}}

-- Core editing {{{
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<leader>qq", "<cmd>qall<CR>", { desc = "Quit Neovim" })

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
map("n", "J", function()
	local view = vim.fn.winsaveview()
	vim.cmd.normal({ args = { vim.v.count1 .. "J" }, bang = true })
	vim.fn.winrestview(view)
end, { desc = "Join lines and keep cursor position" })

map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("x", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("x", "<", "<gv", { desc = "Indent left and reselect" })
map("x", ">", ">gv", { desc = "Indent right and reselect" })

-- Macros {{{
-- Map Q to start recording macros
map("n", "Q", "q", { desc = "Record macro" })
-- Disable the original q key
map("n", "q", "<Nop>", { desc = "Disable macro recording" })
-- }}}
-- }}}

-- Clipboard {{{
local function notify_toggle(title, enabled)
	vim.notify(("%s %s"):format(title, enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

-- OSC52 copy without making the unnamed register depend on terminal paste.
local osc52_copy = require("vim.ui.clipboard.osc52").copy("+")
local system_clipboard_copy = false

map("n", "<leader>tc", function()
	system_clipboard_copy = not system_clipboard_copy
	notify_toggle("System clipboard copy", system_clipboard_copy)
end, { desc = "Toggle system clipboard copy" })
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
		elseif spec.name == "LuaSnip" then
			local result = vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path, text = true }):wait()
			if result.code ~= 0 then
				vim.notify("LuaSnip jsregexp build failed:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
			end
		elseif spec.name == "nvim-treesitter" then
			ensure_loaded()
			vim.cmd.TSUpdate()
		end
	end,
})
-- }}}

-- plugin list {{{
vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1.*") },
	"https://github.com/dmtrKovalenko/fff.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/folke/snacks.nvim",
	{ src = "https://github.com/lmilojevicc/herdr-splits.nvim", version = "v0.5.0" },
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/windwp/nvim-autopairs",
	{ src = "https://github.com/kylechui/nvim-surround", version = vim.version.range("4.*") },
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/rmagatti/auto-session",
	{ src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2.*") },
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/NeogitOrg/neogit",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/dlyongemallo/diffview-plus.nvim",
	"https://github.com/OXY2DEV/markview.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
})
-- }}}
-- }}}

-- Theme {{{
require("catppuccin").setup({
	flavour = "frappe",
	custom_highlights = function(colors)
		return {
			NormalFloat = { fg = colors.text, bg = colors.base },
			FloatBorder = { fg = colors.blue, bg = colors.base },
			BlinkCmpMenu = { fg = colors.overlay2, bg = colors.base },
			BlinkCmpMenuBorder = { fg = colors.blue, bg = colors.base },
		}
	end,
	integrations = {
		blink_cmp = true,
		diffview = true,
		flash = true,
		gitsigns = true,
		grug_far = true,
		markview = true,
		mason = true,
		neogit = true,
		snacks = true,
		trouble = true,
		which_key = true,
	},
})
vim.cmd.colorscheme("catppuccin-frappe")
-- }}}

-- UI chrome {{{
-- File winbar {{{
-- Show file, modified state, and filetype for normal file buffers.
local winbar_str = "%#WinBarFile#%f%* %#WinBarMod#%m%*%=%#WinBarFT#%{&filetype}%*"

local function is_normal_file(buf)
	local bt = vim.bo[buf].buftype
	local fname = vim.api.nvim_buf_get_name(buf)
	return bt == "" and fname ~= ""
end

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	group = group,
	desc = "Show winbar for normal file buffers",
	callback = function()
		vim.wo.winbar = is_normal_file(0) and winbar_str or nil
	end,
})
-- }}}
-- }}}

-- General autocmds {{{
-- Cursor restore {{{
vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	desc = "Restore last cursor position",
	callback = function(ev)
		if ev.buf ~= vim.api.nvim_get_current_buf() then
			return
		end
		local ft = vim.bo[ev.buf].filetype
		if vim.wo.diff or vim.tbl_contains({ "gitcommit", "gitrebase", "xxd" }, ft) then
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(ev.buf, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(ev.buf)

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
		if system_clipboard_copy and vim.v.event.operator == "y" and vim.v.event.regname ~= "_" then
			osc52_copy(vim.v.event.regcontents, vim.v.event.regtype)
		end
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

-- SQL indentation {{{
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "sql",
	desc = "Match SQLFluff's four-space indentation",
	callback = function(ev)
		vim.bo[ev.buf].tabstop = 4
		vim.bo[ev.buf].shiftwidth = 4
	end,
})
-- }}}
-- }}}

-- Plugins {{{
-- snacks {{{
local snacks = require("snacks")
snacks.setup({
	explorer = {
		enabled = true,
		replace_netrw = false, -- Oil remains the default handler for directory buffers.
	},
	indent = { enabled = true },
	picker = {
		enabled = true,
		sources = {
			explorer = {
				hidden = true,
				ignored = true,
			},
		},
	},
})
map("n", "<leader>bd", function()
	snacks.bufdelete()
end, { desc = "Delete buffer keep split" })
map("n", "<leader>bo", function()
	snacks.bufdelete.other()
end, { desc = "Close other buffers" })
map("n", "<leader>e", function()
	snacks.explorer()
end, { desc = "Toggle file explorer" })
map("n", "<leader>fb", function()
	snacks.picker.buffers()
end, { desc = "Find buffers" })
map("n", "<leader>fh", function()
	snacks.picker.help()
end, { desc = "Find help" })
map("n", "<leader>fr", function()
	snacks.picker.resume()
end, { desc = "Resume picker" })
map("n", "<leader>fx", function()
	snacks.picker.diagnostics_buffer()
end, { desc = "Find buffer diagnostics" })
map("n", "<leader>fX", function()
	snacks.picker.diagnostics()
end, { desc = "Find workspace diagnostics" })
-- }}}

-- herdr-splits {{{
local herdr_splits = require("herdr-splits")
herdr_splits.setup()

map("n", "<C-h>", herdr_splits.move_cursor_left, { desc = "Navigate pane left" })
map("n", "<C-j>", herdr_splits.move_cursor_down, { desc = "Navigate pane down" })
map("n", "<C-k>", herdr_splits.move_cursor_up, { desc = "Navigate pane up" })
map("n", "<C-l>", herdr_splits.move_cursor_right, { desc = "Navigate pane right" })
map("n", "<M-h>", herdr_splits.resize_left, { desc = "Resize pane left" })
map("n", "<M-j>", herdr_splits.resize_down, { desc = "Resize pane down" })
map("n", "<M-k>", herdr_splits.resize_up, { desc = "Resize pane up" })
map("n", "<M-l>", herdr_splits.resize_right, { desc = "Resize pane right" })
-- }}}

-- treesitter {{{
require("nvim-treesitter").install({
	"bash",
	"c",
	"css",
	"diff",
	"dockerfile",
	"gitcommit",
	"go",
	"html",
	"htmldjango",
	"javascript",
	"json",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"php",
	"python",
	"query",
	"rust",
	"sql",
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
		if not pcall(vim.treesitter.start, ev.buf) then
			return
		end
		vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

-- Selects + moves; also feeds surround's default `f` via `@call.outer` queries.
require("nvim-treesitter-textobjects").setup({
	select = { lookahead = true },
	move = { set_jumps = true },
})
local ts_select = require("nvim-treesitter-textobjects.select")
local ts_move = require("nvim-treesitter-textobjects.move")
local function sel(capture)
	return function()
		ts_select.select_textobject(capture, "textobjects")
	end
end
map({ "x", "o" }, "af", sel("@function.outer"), { desc = "Around function" })
map({ "x", "o" }, "if", sel("@function.inner"), { desc = "Inner function" })
map({ "x", "o" }, "ac", sel("@class.outer"), { desc = "Around class" })
map({ "x", "o" }, "ic", sel("@class.inner"), { desc = "Inner class" })
map({ "x", "o" }, "aa", sel("@parameter.outer"), { desc = "Around parameter" })
map({ "x", "o" }, "ia", sel("@parameter.inner"), { desc = "Inner parameter" })
map({ "n", "x", "o" }, "]f", function()
	ts_move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function start" })
map({ "n", "x", "o" }, "[f", function()
	ts_move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Prev function start" })
map({ "n", "x", "o" }, "]c", function()
	ts_move.goto_next_start("@class.outer", "textobjects")
end, { desc = "Next class start" })
map({ "n", "x", "o" }, "[c", function()
	ts_move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "Prev class start" })
-- }}}

-- autotag {{{
require("nvim-ts-autotag").setup()
-- }}}

-- fff {{{
map("n", "<leader><SPACE>", function()
	require("fff").find_files()
end, { desc = "FFFind files" })
map("n", "<leader>/", function()
	require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
end, { desc = "Live fffuzy grep" })
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
		-- Replace Oil's default sort picker with Grug Far scoped to this directory.
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
		sql = { "sqlfluff" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
	},
	-- This will also affect the default values for format_on_save/format_after_save
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = function(bufnr)
		return { timeout_ms = vim.bo[bufnr].filetype == "sql" and 2000 or 500 }
	end,
	formatters = {
		-- The shared PostgreSQL config lives outside individual projects.
		sqlfluff = {
			args = { "format", "-" },
			require_cwd = false,
		},
	},
})
map("n", "<leader>cf", function()
	conform.format({ async = true })
end, { desc = "Format buffer" })
-- }}}

-- lint {{{
local lint = require("lint")
lint.linters_by_ft = {
	env = { "dotenv_linter" },
	make = { "checkmake" },
	python = { "ruff" },
	sql = { "sqlfluff" },
}
vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
	group = group,
	pattern = { "*.py", "*.pyi" },
	desc = "Lint Python with Ruff",
	callback = function()
		lint.try_lint()
	end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	desc = "Lint configured filetypes after saving",
	callback = function()
		lint.try_lint()
	end,
})
-- }}}

-- icons {{{
require("nvim-web-devicons").setup({ default = true })
-- }}}

-- snippets {{{
local luasnip = require("luasnip")
luasnip.setup({})
require("luasnip.loaders.from_vscode").lazy_load()

-- Askama templates use HTML snippets alongside their template constructs.
luasnip.filetype_extend("htmldjango", { "html" })
luasnip.add_snippets("htmldjango", require("snippets.htmldjango"), { key = "askama" })
-- }}}

-- blink.cmp {{{
local blink = require("blink.cmp")
local zen_mode = true
blink.setup({
	snippets = { preset = "luasnip" },
	completion = {
		menu = {
			auto_show = function()
				return not zen_mode
			end,
		},
		documentation = { auto_show = true, auto_show_delay_ms = 250 },
	},
	cmdline = {
		completion = {
			menu = {
				auto_show = function()
					return vim.fn.getcmdtype() == ":"
				end,
			},
		},
	},
	signature = { enabled = true },
})
vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
map("n", "<leader>tz", function()
	zen_mode = not zen_mode
	blink.hide()
	notify_toggle("Zen mode", zen_mode)
end, { desc = "Toggle zen mode completion" })
-- }}}

-- autopairs {{{
require("nvim-autopairs").setup({
	check_ts = true,
	disable_filetype = { "TelescopePrompt", "spectre_panel", "fff_input" },
})
-- }}}

-- nvim-surround {{{
require("nvim-surround").setup({})
-- }}}

-- which-key {{{
require("which-key").setup({})
require("which-key").add({
	{ "<leader>b", group = "buffer" },
	{ "<leader>c", group = "code" },
	{ "<leader>f", group = "find" },
	{ "<leader>g", group = "git" },
	{ "<leader>t", group = "toggle" },
})
-- }}}

-- flash {{{
require("flash").setup({})
-- Use lua function rhs (not :lua) so jumps stay dot-repeatable.
map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })
map({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })
map("o", "r", function()
	require("flash").remote()
end, { desc = "Remote Flash" })
map({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Treesitter Search" })
map("c", "<C-s>", function()
	require("flash").toggle()
end, { desc = "Toggle Flash Search" })
-- }}}

-- fidget {{{
require("fidget").setup({})
-- }}}

-- trouble {{{
require("trouble").setup()
-- }}}

-- gitsigns {{{
local gitsigns = require("gitsigns")
gitsigns.setup({
	trouble = true,
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "▁" },
	},
	on_attach = function(bufnr)
		map("n", "<leader>tg", function()
			local enabled = gitsigns.toggle_current_line_blame()
			notify_toggle("Git blame", enabled)
		end, {
			buffer = bufnr,
			desc = "Toggle current line blame",
		})
		map("n", "<leader>go", gitsigns.preview_hunk_inline, {
			buffer = bufnr,
			desc = "Preview Git hunk inline",
		})
		map("n", "<leader>gx", gitsigns.setqflist, {
			buffer = bufnr,
			desc = "Open buffer Git hunks in Trouble",
		})
		map("n", "<leader>gX", function()
			gitsigns.setqflist("all")
		end, {
			buffer = bufnr,
			desc = "Open all Git hunks in Trouble",
		})
	end,
})
-- }}}

-- neogit {{{
local neogit = require("neogit")
neogit.setup({
	integrations = {
		diffview = true,
		snacks = true,
	},
})
map("n", "<leader>gg", neogit.open, { desc = "Open Neogit" })
-- }}}

-- diffview {{{
require("diffview").setup({
	enhanced_diff_hl = true,
	keymaps = {
		view = {
			{ "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
		},
		file_panel = {
			{ "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
		},
		file_history_panel = {
			{ "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
		},
	},
})
map("n", "<leader>gd", "<cmd>DiffviewToggle<CR>", { desc = "Toggle Diffview" })
-- }}}

-- markview {{{
require("markview").setup({
	preview = {
		icon_provider = "devicons",
	},
})
-- }}}

-- sessions {{{
local auto_session = require("auto-session")
auto_session.setup({
	legacy_cmds = false,
	session_lens = { picker = "snacks" },
})
vim.api.nvim_create_user_command("Session", function()
	auto_session.restore_session()
end, { desc = "Resume cwd session" })
vim.api.nvim_create_user_command("SessionClear", function()
	auto_session.delete_session()
	if require("auto-session.config").auto_save then
		auto_session.disable_auto_save()
	end
end, { desc = "Delete cwd session and skip save on quit" })
-- }}}

-- statusline {{{
require("lualine").setup({
	options = {
		theme = "catppuccin-nvim",
		globalstatus = true,
	},
	extensions = { "oil", "quickfix", "trouble" },
})
-- }}}
-- }}}

-- Diagnostics {{{
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
	},
	virtual_lines = false,
	float = {
		border = "rounded",
		source = "if_many",
		header = "",
		prefix = "",
	},
	jump = {
		on_jump = function(diagnostic, bufnr)
			if diagnostic then
				vim.diagnostic.open_float(bufnr, { scope = "cursor", focus = false })
			end
		end,
	},
})
map("n", "<leader>cx", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", {
	desc = "Toggle buffer diagnostics in Trouble",
})
map("n", "<leader>cX", "<cmd>Trouble diagnostics toggle<CR>", {
	desc = "Toggle workspace diagnostics in Trouble",
})
snacks.toggle.diagnostics():map("<leader>td")
-- }}}

-- LSP {{{
-- Esc / float clear {{{
local function close_lsp_floating_previews()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.w[win].lsp_floating_bufnr then
			vim.api.nvim_win_close(win, true)
		end
	end
end
map("n", "<Esc>", function()
	close_lsp_floating_previews()
	vim.cmd.nohlsearch()
end, { silent = true, desc = "Close LSP float and clear search highlight" })
-- }}}

-- LSP keymaps {{{
snacks.keymap.set("n", "gd", vim.lsp.buf.definition, {
	lsp = { method = "textDocument/definition" },
	desc = "Go to definition",
})
snacks.keymap.set("n", "gD", vim.lsp.buf.declaration, {
	lsp = { method = "textDocument/declaration" },
	desc = "Go to declaration",
})
-- }}}

-- Servers {{{
-- nvim-lspconfig supplies default cmd/filetypes/root; only override here.
-- Mason installs binaries; mason-lspconfig auto-enables installed servers.

-- rust-analyzer {{{
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
		},
	},
})
-- }}}

-- phpantom {{{
vim.lsp.config("phpantom_lsp", {
	filetypes = { "php", "blade" },
	root_markers = { "artisan", ".phpantom.toml", "composer.json", ".git" },
})
-- }}}

-- mason {{{
local lsp_servers = {
	"bashls",
	"clangd",
	"cssls",
	"docker_language_server",
	"gopls",
	"html",
	"jsonls",
	"lua_ls",
	"marksman",
	"phpantom_lsp",
	"rust_analyzer",
	"taplo",
	"ts_ls",
	"ty",
	"vimls",
	"yamlls",
}

-- Prefer the active Go toolchain binary over shims that override Mason's GOBIN.
local go_bin = vim.env.GOROOT and vim.fs.joinpath(vim.env.GOROOT, "bin")
if go_bin and vim.fn.isdirectory(go_bin) == 1 then
	vim.env.PATH = go_bin .. ":" .. vim.env.PATH
end

require("mason").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"checkmake",
		"dotenv-linter",
		"gofumpt",
		"goimports",
		"prettier",
		"ruff",
		"shellcheck",
		"sqlfluff",
		"stylua",
	},
})
require("mason-lspconfig").setup({
	ensure_installed = lsp_servers,
	automatic_enable = lsp_servers,
})
-- }}}
-- }}}
-- }}}

-- vim: foldmethod=marker foldlevel=0
