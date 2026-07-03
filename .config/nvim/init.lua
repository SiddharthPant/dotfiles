local map = vim.keymap.set
local M = {}
local pack = vim.pack.add

M.group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

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
vim.o.completeopt = "menuone,noselect,popup" -- completion options
vim.o.laststatus = 3 -- use a single global statusline
vim.o.pumheight = 10 -- popup menu height
vim.o.pumblend = 10 -- popup menu transparency
vim.o.winborder = "rounded" -- rounded borders for floating windows

vim.o.writebackup = false -- do not write to a backup file
vim.o.swapfile = false -- do not create a swapfile
vim.o.undofile = true -- do create an undo file
vim.o.undodir = vim.fn.expand("~/.vim/undodir") -- set the undo directory
vim.o.updatetime = 300 -- faster completion
vim.o.timeoutlen = 500 -- timeout duration
-- Setting it to 0 causes terminals on windows to send OSC11 to send r on startup
vim.o.ttimeoutlen = 10 -- key code timeout.

vim.opt.iskeyword:append("-") -- include - in words
-- vim.o.path:append("**") -- include subdirs in search
vim.o.mouse = "a" -- enable mouse support

vim.o.splitbelow = true -- horizontal splits go below
vim.o.splitright = true -- vertical splits go right

vim.o.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append("linematch:60") -- improve diff display

-- Set a useful terminal title so each pane is distinguishable (dir + file).
-- Tested with ghostty/wezterm; overrides the shell's title while nvim is running.
vim.o.title = true
vim.o.titlestring = "%{fnamemodify(getcwd(),':~')} - %t%(%m%)"

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local function close_lsp_floating_previews()
	local closed = false
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local ok, preview_buf = pcall(function()
			return vim.w[win].lsp_floating_bufnr
		end)
		if ok and preview_buf and vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_close, win, true)
			closed = true
		end
	end
	return closed
end
map("n", "<Esc>", function()
	close_lsp_floating_previews()
	vim.cmd.nohlsearch()
end, { silent = true, desc = "Close LSP float and clear search highlight" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Movement and editing basics
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

-- Splits and buffers
map("n", "<leader>\\", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>-", "<cmd>split<CR>", { desc = "Split window horizontally" })

map("n", "<leader>bd", "<cmd>bn|bd #<CR>", { desc = "Delete buffer keep split" })
local function close_other_buffers()
	local cur = vim.api.nvim_get_current_buf()
	local targets = vim.tbl_filter(function(b)
		return b ~= cur and vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b) and not vim.bo[b].modified
	end, vim.api.nvim_list_bufs())

	for _, b in ipairs(targets) do
		pcall(vim.api.nvim_buf_delete, b, {})
	end
	vim.notify(("Closed %d buffer(s), kept unsaved ones open"):format(#targets), vim.log.levels.INFO)
end
map("n", "<leader>bo", close_other_buffers, { desc = "Close other buffers" })

-- Toggles
local function notify_toggle(title, enabled)
	vim.notify(("%s %s"):format(title, enabled and "enabled" or "disabled"), {
		title = title,
		level = "info",
	})
end

map("n", "<leader>tw", function()
	vim.wo.wrap = not vim.wo.wrap
	notify_toggle("Line wrap", vim.wo.wrap)
end, { desc = "Toggle line wrap" })

map("n", "<leader>td", function()
	local enabled = vim.diagnostic.is_enabled()
	vim.diagnostic.enable(not enabled)
	notify_toggle("Diagnostics", not enabled)
end, { desc = "Toggle diagnostics" })

map("n", "<leader>tc", function()
	local enabled = vim.list_contains(vim.opt.clipboard:get(), "unnamedplus")
	if enabled then
		vim.opt.clipboard:remove("unnamedplus")
	else
		vim.opt.clipboard:append("unnamedplus")
	end
	notify_toggle("System clipboard", not enabled)
end, { desc = "Toggle system clipboard" })

-- Sessions and quit
map("n", "<leader>qq", "<cmd>qall<CR>", { desc = "Quit all" })

-- Misc autocmds

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = M.group,
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

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = M.group,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- close quickfix and location list windows with q
vim.api.nvim_create_autocmd("FileType", {
	group = M.group,
	pattern = "qf",
	callback = function(args)
		vim.keymap.set("n", "q", "<cmd>close<CR>", {
			buffer = args.buf,
			silent = true,
			desc = "Close quickfix window",
		})
	end,
})

-- spellcheck commit messages
vim.api.nvim_create_autocmd("FileType", {
	group = M.group,
	pattern = "gitcommit",
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- Plugin Config

-- Colorscheme: Nord
pack({ "https://github.com/shaunsingh/nord.nvim" })
vim.cmd.colorscheme("nord")

-- File picker: fff.nvim
pack({ "https://github.com/dmtrKovalenko/fff.nvim" })
map("n", "<leader><SPACE>", function()
	require("fff").find_files()
end, { desc = "FFFind files" })
map("n", "<leader>/", function()
	require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
end, { desc = "Live fffuzy grep" })

-- Nice global search/replace UI: grug-far
pack({ "https://github.com/MagicDuck/grug-far.nvim" })

-- Make neovim a well oiled Dir editor: Oil.nvim
pack({ "https://github.com/stevearc/oil.nvim" })
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
					require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
				else
					require("oil").set_columns({ "icon" })
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

-- Reliable file formatting: conform.nvim
pack({ "https://github.com/stevearc/conform.nvim" })
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofumpt" },
		rust = { "rustfmt" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		python = function(bufnr)
			if require("conform").get_formatter_info("ruff_format", bufnr).available then
				return { "ruff_format" }
			else
				return { "isort", "black" }
			end
		end,
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
