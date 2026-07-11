-- Bootstrap {{{
vim.loader.enable()

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

-- Buffers {{{
map("n", "<leader>bd", "<cmd>bn|bd #<CR>", { desc = "Delete buffer keep split" })
local function close_other_buffers()
	local cur = vim.api.nvim_get_current_buf()
	local targets = vim.tbl_filter(function(b)
		return b ~= cur and vim.bo[b].buflisted and not vim.bo[b].modified
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
	"https://github.com/dmtrKovalenko/fff.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/tpope/vim-fugitive",
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
	integrations = {
		diffview = true,
		grug_far = true,
		markview = true,
		mason = true,
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

-- mini {{{
-- icons {{{
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()
-- }}}

-- snippets {{{
-- friendly-snippets supplies HTML snippets; template constructs live in a
-- filetype module so Django-only tags do not leak into Askama files.
local gen_loader = require("mini.snippets").gen_loader
local from_lang = gen_loader.from_lang({
	lang_patterns = {
		html = { "html.json" },
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

local askama_snippets = require("snippets.htmldjango")

require("mini.snippets").setup({
	snippets = {
		function(context)
			if context and vim.bo[context.buf_id].filetype == "htmldjango" then
				-- Treesitter may report an injected language; use HTML snippets plus
				-- the Askama set for this template filetype.
				local html_context = vim.tbl_extend("force", {}, context, { lang = "html" })
				return { from_lang(html_context), askama_snippets }
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

-- autopairs {{{
local npairs = require("nvim-autopairs")

npairs.setup({
	check_ts = true,
	map_cr = false,
	disable_filetype = { "TelescopePrompt", "spectre_panel", "fff_input" },
})

-- Confirm a selected completion item; otherwise dismiss the popup and run
-- nvim-autopairs' normal CR behavior.
vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() ~= 0 then
		if vim.fn.complete_info({ "selected" }).selected ~= -1 then
			return npairs.esc("<C-y>")
		end
		return npairs.esc("<C-e>") .. npairs.autopairs_cr()
	end
	return npairs.autopairs_cr()
end, { expr = true, replace_keycodes = false, desc = "autopairs CR" })
-- }}}

-- which-key {{{
require("which-key").setup({})
require("which-key").add({
	{ "<leader>b", group = "buffer" },
	{ "<leader>c", group = "code" },
	{ "<leader>g", group = "git" },
	{ "<leader>t", group = "toggle" },
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
})
-- }}}

-- markview {{{
require("markview").setup({
	preview = {
		icon_provider = "mini",
	},
})
-- }}}

-- sessions {{{
-- Per-cwd sessions under stdpath("data")/session (not in the project tree).
-- :SessionClear deletes it and skips save for this Neovim instance.
local session_save = true
require("mini.sessions").setup({
	autowrite = false,
	file = "",
	verbose = { write = false, delete = false },
})
local function session_cwd()
	return vim.fn.getcwd(-1, -1)
end

local function session_name()
	local cwd = session_cwd()
	local base = vim.fn.fnamemodify(cwd, ":t")
	return ("%s-%s"):format(base == "" and "root" or base, vim.fn.sha256(cwd):sub(1, 12))
end

vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	nested = true,
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
		local ok, err = pcall(MiniSessions.write, session_name())
		if not ok then
			vim.notify(("Failed to save session: %s"):format(err), vim.log.levels.ERROR)
		end
	end,
})
vim.api.nvim_create_user_command("Session", function()
	MiniSessions.read(session_name())
end, { desc = "Resume cwd session" })
vim.api.nvim_create_user_command("SessionClear", function()
	local name = session_name()
	if MiniSessions.detected[name] then
		local ok, err = pcall(MiniSessions.delete, name, { force = true })
		if not ok then
			vim.notify(("Failed to delete session: %s"):format(err), vim.log.levels.ERROR)
		end
	end
	session_save = false
end, { desc = "Delete cwd session and skip save on quit" })
-- }}}

-- statusline {{{
require("mini.statusline").setup()
-- }}}
-- }}}
-- }}}

-- Diagnostics {{{
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	jump = {
		on_jump = function(diagnostic, bufnr)
			if diagnostic then
				vim.diagnostic.open_float(bufnr, { scope = "cursor", focus = false })
			end
		end,
	},
})
map("n", "<leader>cx", function()
	vim.diagnostic.setloclist({ open = true, title = "Diagnostics" })
end, { desc = "Open location list with buffer diagnostics" })
map("n", "<leader>cX", function()
	vim.diagnostic.setqflist({ open = true, title = "Workspace diagnostics" })
end, { desc = "Open quickfix list with all diagnostics" })
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

-- LspAttach {{{
vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end

		if client:supports_method("textDocument/definition", ev.buf) then
			map("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
		end
		if client:supports_method("textDocument/declaration", ev.buf) then
			map("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
		end
	end,
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
