-- Bootstrap
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

-- Options
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd("colorscheme catppuccin")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

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
vim.o.showmatch = true -- highlights matching brackets
vim.o.listchars = "tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•" -- make hidden characters readable
vim.o.laststatus = 3 -- use a single global statusline
-- Add the effective file encoding to Neovim's native statusline.
vim.o.statusline = vim.o.statusline .. " %{&fileencoding ==# '' ? &encoding : &fileencoding}"
vim.o.pumheight = 10 -- popup menu height
vim.o.pumblend = 10 -- popup menu transparency
-- vim.o.autocomplete = true -- show native keyword completion automatically while typing
vim.o.completeopt = "menuone,noselect,popup,fuzzy" -- show completion without selecting an item
vim.o.winborder = "rounded" -- rounded borders for floating windows

vim.o.writebackup = false -- do not write to a backup file
vim.o.swapfile = false -- do not create a swapfile
vim.o.undofile = true -- do create an undo file

vim.opt.iskeyword:append("-") -- include - in words
vim.o.splitbelow = true -- horizontal splits go below
vim.o.splitright = true -- vertical splits go right

vim.o.wildmode = "noselect:lastused,full" -- show completion without selecting, then cycle through with Tab
vim.o.wildmenu = true
vim.o.wildoptions = "fuzzy,pum"
vim.o.wildignorecase = true
vim.opt.wildignore:append({ ".git", "node_modules", "target", "vendor", "dist", "*.o", "*.swp" })
vim.api.nvim_create_autocmd("CmdlineChanged", {
	group = group,
	pattern = ":",
	callback = function()
		vim.fn.wildtrigger()
	end,
})
vim.opt.diffopt:append("linematch:60") -- improve diff display
vim.opt.diffopt:append("algorithm:histogram") -- align changes using surrounding code structure
vim.opt.diffopt:append("indent-heuristic") -- shift hunk boundaries to more readable locations

-- Set a useful terminal title so each pane is distinguishable (dir + file).
-- Tested with ghostty/wezterm; overrides the shell's title while nvim is running.
vim.o.title = true
vim.o.titlestring = "%{fnamemodify(getcwd(),':~')} - %t%(%m%)"

-- Core editing
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<leader>qq", "<cmd>qall<CR>", { desc = "Quit Neovim" })
map("n", "<leader>rr", "<cmd>restart<CR>", { desc = "Restart Neovim" })
map("n", "<Esc>", function()
	vim.cmd.nohlsearch()
end, { silent = true, desc = "Clear search highlight" })

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

-- Macros
-- Map Q to start recording macros
map("n", "Q", "q", { desc = "Record macro" })
-- Disable the original q key
map("n", "q", "<Nop>", { desc = "Disable macro recording" })

-- Clipboard
local function notify_toggle(title, enabled)
	vim.notify(("%s %s"):format(title, enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

map("n", "<leader>th", function()
	vim.wo.list = not vim.wo.list
	notify_toggle("Hidden characters", vim.wo.list)
end, { desc = "Toggle hidden characters" })

-- OSC52 copy without making the unnamed register depend on terminal paste.
local osc52_copy = require("vim.ui.clipboard.osc52").copy("+")
local system_clipboard_copy = false

map("n", "<leader>tc", function()
	system_clipboard_copy = not system_clipboard_copy
	notify_toggle("System clipboard copy", system_clipboard_copy)
end, { desc = "Toggle system clipboard copy" })

-- plugin list
vim.g.compile_mode = {
	default_command = "mise lint",
	baleia_setup = true,
	recompile_no_fail = true,
	ask_to_interrupt = false,
	use_circular_error_navigation = true,
	environment = {
		CARGO_TERM_COLOR = "always",
	},
	error_regexp_table = {
		rust = {
			regex = [[^\s*-->\s\+\(.\+\):\([0-9]\+\):\([0-9]\+\)$]],
			filename = 1,
			row = 2,
			col = 3,
		},
	},
}
vim.pack.add({
	{ src = "https://github.com/m00qek/baleia.nvim", version = "v1.3.0" },
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/ej-shafran/compile-mode.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/notjedi/nvim-rooter.lua",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/dlyongemallo/diffview-plus.nvim",
	"https://codeberg.org/andyg/leap.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/rmagatti/auto-session",
})

-- UI chrome
-- File winbar
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

-- General autocmds
-- Cursor restore
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

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.hl.on_yank()
		if system_clipboard_copy and vim.v.event.operator == "y" and vim.v.event.regname ~= "_" then
			osc52_copy(vim.v.event.regcontents, vim.v.event.regtype)
		end
	end,
})

-- Gitcommit spell
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "gitcommit",
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- Plugins
-- navigation
local fzf = require("fzf-lua")
fzf.setup({
	fzf_colors = true,
	winopts = {
		split = "belowright 10new",
		preview = { hidden = true },
	},
	files = {
		file_icons = false,
		git_icons = true,
	},
	grep = {
		hidden = true,
	},
	buffers = {
		file_icons = false,
		git_icons = true,
	},
	fzf_opts = { ["--layout"] = "default" },
})

map("n", "<leader>ff", function()
	local opts = {
		cmd = "fd --color=never --hidden --type f --type l --exclude .git",
		fzf_opts = {
			["--scheme"] = "path",
			["--tiebreak"] = "index",
			["--layout"] = "default",
		},
	}
	local base = vim.fn.fnamemodify(vim.fn.expand("%"), ":h:.:S")
	if base ~= "." and vim.fn.executable("proximity-sort") == 1 then
		opts.cmd = opts.cmd .. (" | proximity-sort %s"):format(vim.fn.shellescape(vim.fn.expand("%")))
	end
	fzf.files(opts)
end, { desc = "Find project files" })
map("n", "<leader><Space>", function()
	fzf.buffers({
		fzf_opts = {
			["--with-nth"] = "{-3..-2}",
			["--nth"] = "-1",
			["--delimiter"] = "[: ]",
			["--header-lines"] = "false",
		},
		header = false,
	})
end, { desc = "Find buffers" })
map("n", "<leader>/", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>fh", fzf.helptags, { desc = "Find help" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume picker" })

require("nvim-rooter").setup()

map({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Leap" })

-- git
vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "GitSignsUpdate",
	desc = "Set Gitsigns buffer mappings after attachment",
	callback = function(ev)
		local bufnr = ev.data and ev.data.buffer
		if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end
		map("n", "<leader>go", require("gitsigns").preview_hunk_inline, {
			buffer = bufnr,
			desc = "Preview Git hunk inline",
		})
	end,
})

local close_diffview = "<cmd>DiffviewClose<cr>"
require("diffview").setup({
	use_icons = false,
	keymaps = {
		view = {
			{ "n", "q", close_diffview, { desc = "Close Diffview" } },
		},
		file_panel = {
			{ "n", "q", close_diffview, { desc = "Close Diffview" } },
		},
	},
})
map("n", "<leader>gg", "<cmd>DiffviewToggle<cr>", { desc = "Toggle Diffview" })

local function listed_buffers()
	return vim.tbl_filter(function(bufnr)
		return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
	end, vim.api.nvim_list_bufs())
end

map("n", "<leader>bd", function()
	local current = vim.api.nvim_get_current_buf()
	if vim.bo[current].modified then
		vim.notify("Buffer has unsaved changes", vim.log.levels.WARN)
		return
	end
	if #listed_buffers() == 1 then
		vim.cmd.enew()
	else
		vim.cmd.bnext()
	end
	vim.api.nvim_buf_delete(current, {})
end, { desc = "Delete buffer keep split" })
map("n", "<leader>bo", function()
	local current = vim.api.nvim_get_current_buf()
	local closed = 0
	local modified = 0
	for _, bufnr in ipairs(listed_buffers()) do
		if bufnr ~= current then
			if vim.bo[bufnr].modified then
				modified = modified + 1
			else
				vim.api.nvim_buf_delete(bufnr, {})
				closed = closed + 1
			end
		end
	end
	local message = ("Closed %d other buffer%s"):format(closed, closed == 1 and "" or "s")
	if modified > 0 then
		message = ("%s; kept %d modified buffer%s"):format(message, modified, modified == 1 and "" or "s")
	end
	vim.notify(message, vim.log.levels.INFO)
end, { desc = "Close other buffers" })

-- oil
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

-- which-key
require("which-key").setup({})
require("which-key").add({
	{ "<leader>b", group = "buffer" },
	{ "<leader>f", group = "find" },
	{ "<leader>t", group = "toggle" },
})

-- fidget
require("fidget").setup({})

-- sessions
local auto_session = require("auto-session")
auto_session.setup({
	legacy_cmds = false,
	session_lens = { picker = "fzf" },
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
