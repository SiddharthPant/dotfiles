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
vim.o.listchars = "tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•" -- make hidden characters readable
vim.o.laststatus = 3 -- use a single global statusline
-- Neovim's native statusline already reports buffer diagnostics; add the effective file encoding.
vim.o.statusline = vim.o.statusline .. " %{&fileencoding ==# '' ? &encoding : &fileencoding}"
vim.o.pumheight = 10 -- popup menu height
vim.o.pumblend = 10 -- popup menu transparency
vim.o.pumborder = "rounded"
vim.o.completeopt = "menuone,noselect,popup" -- show completion without selecting an item
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
vim.opt.sessionoptions:append("localoptions") -- preserve buffer-local options in sessions

-- Set a useful terminal title so each pane is distinguishable (dir + file).
-- Tested with ghostty/wezterm; overrides the shell's title while nvim is running.
vim.o.title = true
vim.o.titlestring = "%{fnamemodify(getcwd(),':~')} - %t%(%m%)"

-- Core editing
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<leader>qq", "<cmd>qall<CR>", { desc = "Quit Neovim" })
map("n", "<leader>rr", "<cmd>restart<CR>", { desc = "Restart Neovim" })

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

-- Pack
-- install/update hooks
-- Must be registered before pack() so PackChanged events are seen.
require("treesitter.askama").setup()
vim.api.nvim_create_autocmd("PackChanged", {
	group = group,
	desc = "Post-install hooks for plugins that need a build step",
	callback = function(ev)
		local spec = ev.data.spec
		local kind = ev.data.kind
		if not spec or (kind ~= "install" and kind ~= "update") then
			return
		end
		if spec.name == "nvim-treesitter" then
			if not ev.data.active then
				vim.cmd.packadd(spec.name)
			end
			vim.cmd.TSUpdate()
		end
	end,
})

-- plugin list
vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/folke/snacks.nvim",
	"https://github.com/notjedi/nvim-rooter.lua",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/dlyongemallo/diffview-plus.nvim",
	"https://codeberg.org/andyg/leap.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/rmagatti/auto-session",
	"https://github.com/OXY2DEV/markview.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/b0o/SchemaStore.nvim",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
})

-- Theme
require("catppuccin").setup({
	flavour = "frappe",
	integrations = {
		diffview = true,
		fzf = true,
		gitsigns = true,
		grug_far = true,
		markview = true,
		mason = true,
		snacks = { enabled = true },
		which_key = true,
	},
})
vim.cmd.colorscheme("catppuccin-frappe")

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

-- SQL indentation
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "sql",
	desc = "Match SQLFluff's four-space indentation",
	callback = function(ev)
		vim.bo[ev.buf].tabstop = 4
		vim.bo[ev.buf].shiftwidth = 4
	end,
})

-- Plugins
-- navigation
require("snacks").setup({
	explorer = {
		enabled = true,
		replace_netrw = false,
	},
	indent = {
		enabled = true,
	},
})
map("n", "<leader>e", function()
	Snacks.explorer({ hidden = true, ignored = true })
end, { desc = "File explorer" })

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
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Find buffer symbols" })
map("n", "<leader>fS", fzf.lsp_live_workspace_symbols, { desc = "Find workspace symbols" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume picker" })
map("n", "<leader>fx", fzf.diagnostics_document, { desc = "Find buffer diagnostics" })
map("n", "<leader>fX", fzf.diagnostics_workspace, { desc = "Find workspace diagnostics" })

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
map("n", "<leader>gd", "<cmd>DiffviewToggle<cr>", { desc = "Toggle Diffview" })

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

-- treesitter
require("nvim-treesitter").install({
	"bash",
	"c",
	"css",
	"diff",
	"dockerfile",
	"gitcommit",
	"go",
	"html",
	"askama",
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

local function ancestor_file_contains(path, filename, text)
	local files = vim.fs.find(filename, {
		path = vim.fs.dirname(path),
		upward = true,
		type = "file",
		limit = math.huge,
	})
	for _, file in ipairs(files) do
		local ok, lines = pcall(vim.fn.readfile, file)
		if ok and table.concat(lines, "\n"):find(text, 1, true) then
			return true
		end
	end
	return false
end

-- Distinguish Askama and Django projects whose templates share the same paths.
vim.filetype.add({
	pattern = {
		[".*/templates/.*%.html"] = function(path)
			if ancestor_file_contains(path, "Cargo.toml", "askama") then
				return "askama"
			end
			if vim.fs.root(vim.fs.dirname(path), "manage.py") then
				return "htmldjango"
			end
		end,
	},
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Enable treesitter highlighting when a parser exists",
	callback = function(ev)
		pcall(vim.treesitter.start, ev.buf)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "askama",
	desc = "Use HTML indentation for Askama templates",
	callback = function(ev)
		vim.api.nvim_buf_call(ev.buf, function()
			vim.cmd("runtime! indent/html.vim")
		end)
	end,
})

-- Treesitter text-object selection and movement.
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

-- autotag
require("nvim-ts-autotag").setup()

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

-- conform
local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofumpt" },
		askama = { "askama_fmt" },
		htmldjango = { "djlint" },
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
		askama_fmt = {
			command = "askama_fmt",
			args = { "--stdin-filepath", "$FILENAME" },
			stdin = true,
		},
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

-- lint
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

-- which-key
require("which-key").setup({})
require("which-key").add({
	{ "<leader>b", group = "buffer" },
	{ "<leader>c", group = "code" },
	{ "<leader>f", group = "find" },
	{ "<leader>t", group = "toggle" },
})

-- fidget
require("fidget").setup({})

-- markview
require("markview").setup({
	preview = {
		icon_provider = "internal",
	},
})

-- sessions
local auto_session = require("auto-session")
local function redetect_template_filetypes()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local path = vim.api.nvim_buf_get_name(bufnr)
		if vim.api.nvim_buf_is_loaded(bufnr) and path:match("/templates/.*%.html$") then
			local filetype = vim.filetype.match({ buf = bufnr })
			if filetype and vim.bo[bufnr].filetype ~= filetype then
				vim.bo[bufnr].filetype = filetype
			end
		end
	end
end
auto_session.setup({
	legacy_cmds = false,
	post_restore_cmds = { redetect_template_filetypes },
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

-- Diagnostics
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
map("n", "<leader>td", function()
	local enabled = not vim.diagnostic.is_enabled()
	vim.diagnostic.enable(enabled)
	notify_toggle("Diagnostics", enabled)
end, { desc = "Toggle diagnostics" })

-- LSP
-- Completion
local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
lsp_capabilities.textDocument.completion.completionItem.snippetSupport = false
lsp_capabilities.textDocument.completion.completionItemKind.valueSet = vim.tbl_filter(function(kind)
	return kind ~= vim.lsp.protocol.CompletionItemKind.Snippet
end, lsp_capabilities.textDocument.completion.completionItemKind.valueSet)
vim.lsp.config("*", { capabilities = lsp_capabilities })

vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	desc = "Enable manual native LSP completion",
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, {
				autotrigger = false,
			})
		end
		if client:supports_method("textDocument/definition") then
			map("n", "gd", vim.lsp.buf.definition, {
				buffer = args.buf,
				desc = "Go to definition",
			})
		end
		if client:supports_method("textDocument/declaration") then
			map("n", "gD", vim.lsp.buf.declaration, {
				buffer = args.buf,
				desc = "Go to declaration",
			})
		end
	end,
})

-- Esc / float clear
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

-- Servers
-- nvim-lspconfig supplies default cmd/filetypes/root; only override here.
-- Mason installs binaries; mason-lspconfig auto-enables installed servers.

-- jsonls
vim.lsp.config("jsonls", {
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
})

-- rust-analyzer
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
			completion = {
				postfix = {
					enable = false,
				},
			},
		},
	},
})

-- phpantom
vim.lsp.config("phpantom_lsp", {
	filetypes = { "php", "blade" },
	root_markers = { "artisan", ".phpantom.toml", "composer.json", ".git" },
})

-- mason
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
		"djlint",
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
