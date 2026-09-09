-- Bootstrap
vim.loader.enable()
require("vim._core.ui2").enable({
	msg = {
		pager = { height = 0.5 },
		msg = { timeout = 4500 },
	},
})

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local map = vim.keymap.set
local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Options
vim.opt.termguicolors = true
vim.opt.background = "dark"

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
vim.o.autocomplete = false -- Blink owns automatic completion
vim.o.winborder = "rounded" -- rounded borders for floating windows

vim.o.writebackup = false -- do not write to a backup file
vim.o.swapfile = false -- do not create a swapfile
vim.o.undofile = true -- do create an undo file

vim.opt.iskeyword:append("-") -- include - in words
vim.o.splitbelow = true -- horizontal splits go below
vim.o.splitright = true -- vertical splits go right
vim.o.splitkeep = "screen" -- keep text stable when splits change size

vim.o.wildignorecase = true
vim.opt.wildignore:append({ ".git", "node_modules", "target", "vendor", "dist", "*.o", "*.swp" })
vim.cmd("set diffopt+=algorithm:histogram")

-- Bundled optional plugins
for _, plugin in ipairs({
	"nvim.undotree", -- interactive undo history
	"nvim.difftool", -- file and directory comparisons
	"cfilter", -- filter quickfix and location lists
	"nohlsearch", -- clear search highlights on idle or InsertEnter
	"nvim.tohtml", -- export highlighted buffers as HTML
	"justify", -- justify text
}) do
	vim.cmd.packadd({ plugin, bang = true }) -- load plugin scripts once during startup
end

-- netrw
vim.g.netrw_liststyle = 3 -- set layout to tree view style
vim.g.netrw_winsize = 25 -- set the width percent of explorer window

-- Set a useful terminal title so each pane is distinguishable (dir + file).
-- Tested with ghostty/wezterm; overrides the shell's title while nvim is running.
vim.o.title = true
vim.o.titlestring = "%{fnamemodify(getcwd(),':~')} - %t%(%m%)"

-- Core editing
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
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
map("n", "<leader>zj", "zcjzo", { desc = "Close fold and open next" })
map("n", "<leader>zk", "zckzo", { desc = "Close fold and open previous" })
map("n", "J", function()
	local view = vim.fn.winsaveview()
	vim.cmd.normal({ args = { vim.v.count1 .. "J" }, bang = true })
	vim.fn.winrestview(view)
end, { desc = "Join lines and keep cursor position" })

map("x", "<", "<gv", { desc = "Indent left and reselect" })
map("x", ">", ">gv", { desc = "Indent right and reselect" })

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
vim.api.nvim_create_autocmd("PackChanged", {
	group = group,
	callback = function(ev)
		if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
			vim.schedule(function()
				require("nvim-treesitter").update()
			end)
		end
	end,
})
vim.pack.add({
	{ src = "https://github.com/m00qek/baleia.nvim", version = "v1.3.0" },
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/ej-shafran/compile-mode.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/notjedi/nvim-rooter.lua",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/dlyongemallo/diffview-plus.nvim",
	"https://codeberg.org/andyg/leap.nvim",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/rmagatti/auto-session",
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	"https://github.com/HiPhish/rainbow-delimiters.nvim",
	{ src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" },
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
})

require("catppuccin").setup({
	integrations = { rainbow_delimiters = true },
})
vim.cmd.colorscheme("catppuccin")

-- Tree-sitter: parser installation and highlighting are separate.
local treesitter_parsers = {
	"rust",
	"lua",
	"luadoc",
	"vim",
	"vimdoc",
	"query",
	"javascript",
	"typescript",
	"tsx",
	"html",
	"css",
	"json",
	"toml",
	"bash",
	"yaml",
	"markdown",
	"markdown_inline",
}
require("nvim-treesitter").install(treesitter_parsers)
require("nvim-treesitter-textobjects").setup({
	select = { lookahead = true },
})
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
		-- On first startup, downloads may still be running; reopen the buffer afterward.
		if lang and vim.tbl_contains(treesitter_parsers, lang) and vim.treesitter.language.add(lang) then
			vim.treesitter.start(ev.buf, lang)
			if not vim.treesitter.query.get(lang, "textobjects") then
				return
			end
			for key, capture in pairs({
				af = "@function.outer",
				["if"] = "@function.inner",
				aa = "@parameter.outer",
				ia = "@parameter.inner",
				ac = "@class.outer",
				ic = "@class.inner",
			}) do
				map({ "x", "o" }, key, function()
					require("nvim-treesitter-textobjects.select").select_textobject(capture, "textobjects")
				end, { buffer = ev.buf, desc = "Select " .. capture:sub(2) })
			end
			for key, method in pairs({
				["<leader>a"] = "swap_next",
				["<leader>A"] = "swap_previous",
			}) do
				map("n", key, function()
					require("nvim-treesitter-textobjects.swap")[method]("@parameter.inner", "textobjects")
				end, { buffer = ev.buf, desc = method:gsub("_", " ") .. " argument" })
			end
			for key, method in pairs({
				["]f"] = "goto_next_start",
				["[f"] = "goto_previous_start",
				["]F"] = "goto_next_end",
				["[F"] = "goto_previous_end",
			}) do
				map({ "n", "x", "o" }, key, function()
					require("nvim-treesitter-textobjects.move")[method]("@function.outer", "textobjects")
				end, { buffer = ev.buf, desc = method:gsub("_", " ") .. " function" })
			end
		end
	end,
})

-- Completion: Blink owns insert and command-line menus.
require("lazydev").setup({})
require("blink.cmp").setup({
	cmdline = {
		keymap = {
			-- the default keymap will only show and select the next item
			["<Tab>"] = { "show", "accept" },
		},
		completion = {
			menu = { auto_show = true },
		},
	},
	signature = { enabled = true },
	sources = {
		per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
		providers = {
			lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
		},
	},
	keymap = {
		["<C-u>"] = { "scroll_signature_up", "fallback" },
		["<C-d>"] = { "scroll_signature_down", "fallback" },
	},
})

-- LSP: Mason installs tools; lspconfig supplies server defaults.
require("mason").setup()
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})
vim.diagnostic.config({ virtual_lines = { current_line = true } })
local language_servers = { "rust_analyzer", "lua_ls", "ts_ls", "html", "cssls", "jsonls", "bashls", "taplo", "yamlls" }
require("mason-lspconfig").setup({
	ensure_installed = language_servers,
	automatic_enable = language_servers,
})
require("mason-tool-installer").setup({
	ensure_installed = { "stylua", "prettier", "shfmt", "taplo" },
	integrations = { ["mason-lspconfig"] = false },
})
vim.lsp.inlay_hint.enable(true)
vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(ev)
		map("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/inlayHint") then
			map("n", "<leader>ti", function()
				local enabled = not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
				vim.lsp.inlay_hint.enable(enabled, { bufnr = ev.buf })
				notify_toggle("Inlay hints", enabled)
			end, { buffer = ev.buf, desc = "Toggle inlay hints" })
		end
	end,
})

-- Formatting: Conform is the sole format-on-save handler.
local function html_formatters(bufnr)
	if vim.api.nvim_buf_get_name(bufnr):match("%.html$") and vim.fs.root(bufnr, "Cargo.toml") then
		return { "askama_fmt" }
	end
	return vim.bo[bufnr].filetype == "html" and { "prettier" } or {}
end
require("conform").setup({
	formatters = {
		askama_fmt = {
			command = "askama_fmt",
			args = { "--stdin-filepath", "$FILENAME" },
			stdin = true,
		},
	},
	formatters_by_ft = {
		rust = { "rustfmt" }, -- use the project's Rust toolchain
		lua = { "stylua" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		html = html_formatters,
		htmldjango = html_formatters,
		css = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		toml = { "taplo" },
		sh = { "shfmt" },
		bash = { "shfmt" },
	},
	format_on_save = function(bufnr)
		if vim.bo[bufnr].buftype ~= "" then
			return
		end
		return { timeout_ms = 2000, lsp_format = "never" }
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
			osc52_copy(vim.v.event.regcontents)
		end
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

map("n", "<leader><Space>", function()
	local opts = {
		cmd = "fd --color=never --hidden --type f --type l --exclude .git",
		fzf_opts = {
			["--scheme"] = "path",
			["--tiebreak"] = "index",
		},
	}
	local base = vim.fn.fnamemodify(vim.fn.expand("%"), ":h:.:S")
	if base ~= "." and vim.fn.executable("proximity-sort") == 1 then
		opts.cmd = opts.cmd .. (" | proximity-sort %s"):format(vim.fn.shellescape(vim.fn.expand("%")))
	end
	fzf.files(opts)
end, { desc = "Find project files" })
map("n", "<leader><BS>", function()
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
map("n", "<leader>?", fzf.grep_cword, { desc = "Grep word under cursor" })
map("n", "<leader>fh", fzf.helptags, { desc = "Find help" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume picker" })

require("nvim-rooter").setup()

map({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Leap" })

-- git
require("gitsigns").setup({
	on_attach = function(bufnr)
		map("n", "<leader>go", require("gitsigns").preview_hunk_inline, {
			buffer = bufnr,
			desc = "Preview Git hunk inline",
		})
	end,
})

local close_diffview = "<cmd>DiffviewClose<cr>"
require("diffview").setup({
	preferred_adapter = "jj",
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
	local buffers = listed_buffers()
	local replacement
	if #buffers > 1 or (#buffers == 1 and buffers[1] ~= current) then
		vim.cmd.bnext()
		replacement = vim.api.nvim_get_current_buf()
	else
		replacement = vim.api.nvim_create_buf(true, false)
	end
	-- Replace the buffer in every split/tab before deleting it to preserve windows.
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == current then
			vim.api.nvim_win_set_buf(win, replacement)
		end
	end
	vim.api.nvim_buf_delete(current, {})
end, { desc = "Delete buffer keep splits" })
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
local detail = false
oil.setup({
	default_file_explorer = false,
	delete_to_trash = true,
	view_options = {
		show_hidden = true,
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
