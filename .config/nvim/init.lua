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
vim.opt.completeopt = { "fuzzy", "menuone", "noselect", "popup" } -- completion options
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

-- Sessions and quit
map("n", "<leader>qq", "<cmd>qall<CR>", { desc = "Quit all" })

-- Map Q to start recording macros
map("n", "Q", "q", { desc = "Record macro" })
-- Disable the original q key
map("n", "q", "<Nop>", { desc = "Disable macro recording" })

-- Misc autocmds

-- Winbar: show only on INACTIVE normal-file windows
local winbar_str = "%#WinBarFile#%f%* %#WinBarMod#%m%*%=%#WinBarFT#%{&filetype}%*"

local function is_normal_file(buf)
	local bt = vim.bo[buf].buftype
	local fname = vim.api.nvim_buf_get_name(buf)
	return bt == "" and fname ~= ""
end

-- Window becoming active: hide its winbar
vim.api.nvim_create_autocmd("WinEnter", {
	group = M.group,
	desc = "Hide winbar on the now-active window",
	callback = function()
		vim.wo.winbar = nil
	end,
})

-- Window becoming inactive: show winbar if it's a normal file buffer
vim.api.nvim_create_autocmd("WinLeave", {
	group = M.group,
	desc = "Show winbar on the now-inactive window (normal files only)",
	callback = function()
		if is_normal_file(0) then
			vim.wo.winbar = winbar_str
		else
			vim.wo.winbar = nil
		end
	end,
})

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
-- Overrides and autocmds to auto-completion info window backgrounds
vim.api.nvim_set_hl(0, "CmpDocNormal", { bg = "#3B4252", fg = "#D8DEE9" }) -- nord1 bg, nord4 fg
vim.api.nvim_set_hl(0, "CmpDocBorder", { bg = "#3B4252", fg = "#88C0D0" }) -- nord8 border
-- match nord's WinBar background so segments blend with the bar
local winbar_bg = "#3B4252" -- nord0; change to "#3B4252" (nord1) if you want it slightly raised
vim.api.nvim_set_hl(0, "WinBar", { bg = winbar_bg, fg = "#D8DEE9" }) -- nord4 fg for filler/uncolored text
vim.api.nvim_set_hl(0, "WinBarNC", { bg = winbar_bg, fg = "#4C566A" }) -- nord3 dim for non-current window
vim.api.nvim_set_hl(0, "WinBarFile", { bg = winbar_bg, fg = "#88C0D0", bold = true }) -- nord8 cyan filename
vim.api.nvim_set_hl(0, "WinBarMod", { bg = winbar_bg, fg = "#BF616A", bold = true }) -- nord11 red [+]
vim.api.nvim_set_hl(0, "WinBarFT", { bg = winbar_bg, fg = "#81A1C1" }) -- nord9 dim cyan filetype
vim.api.nvim_set_hl(0, "StatusLineErr", { fg = "#BF616A", bold = true }) -- nord11
vim.api.nvim_set_hl(0, "StatusLineWarn", { fg = "#D08770" }) -- nord12

vim.api.nvim_create_autocmd("CompleteChanged", {
	group = M.group,
	callback = function()
		local preview = vim.fn.complete_info({ "selected" }).preview_winid
		if preview and vim.api.nvim_win_is_valid(preview) then
			-- reuse existing position; only add a border
			vim.api.nvim_win_set_config(preview, { border = "rounded" })
			vim.wo[preview].winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder"
		end
	end,
})

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

-- Reliable file formatting: conform.nvim
pack({ "https://github.com/stevearc/conform.nvim" })
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

-- The one and only best git manager for vim
pack({ "https://github.com/tpope/vim-fugitive" })

-- Helpful keymaps with which-key
pack({ "https://github.com/folke/which-key.nvim" })
-- local wk = require("which-key")
-- wk.setup({
--
-- })
-- wk.show({
-- 	keys = "C-w",
-- 	loop = true,
-- })

-- LSP and Diagnostics

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	signs = true,
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

vim.api.nvim_create_autocmd("InsertCharPre", {
	group = vim.api.nvim_create_augroup("my-lsp-completion", { clear = true }),
	callback = function()
		if vim.fn.pumvisible() == 1 then
			return
		end

		if vim.v.char:match("[%w_]") then
			vim.lsp.completion.get()
		end
	end,
})
map("i", "<C-Space>", function()
	vim.lsp.completion.get()
end, { desc = "Trigger LSP completion" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my-lsp", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end

		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, {
				autotrigger = true,
			})
		end

		map("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
		map("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
		map("n", "<leader>cf", function()
			conform.format({ bufnr = ev.buf, async = true, lsp_format = "fallback" })
		end, { buffer = ev.buf, desc = "Format buffer" })
	end,
})

local function lsp(name, cfg)
	if vim.fn.executable(cfg.cmd[1]) == 0 then
		return
	end

	vim.lsp.config(name, cfg)
	vim.lsp.enable(name)
end

local lua_library = { vim.env.VIMRUNTIME }
lsp("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"init.lua",
		".git",
	},
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = lua_library,
			},
			completion = {
				callSnippet = "Replace",
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

lsp("rust_analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", "rust-project.json", ".git" },
})

lsp("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
})

lsp("ty", {
	cmd = { "ty", "server" },
	filetypes = { "python" },
	root_markers = {
		"ty.toml",
		"pyproject.toml",
		"uv.lock",
		"requirements.txt",
		".git",
	},
})

lsp("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})

lsp("phpantom", {
	cmd = { "phpantom_lsp" },
	filetypes = { "php", "blade" },
	root_markers = { "artisan", "composer.json", ".git" },
	settings = {
		intelephense = {
			files = {
				associations = { "*.php", "*.blade.php" },
			},
		},
	},
})

local snippets = {
	lua = {
		req = 'local ${1:name} = require("${2:module}")',
		fn = "local function ${1:name}(${2:args})\n\t${0}\nend",
		map = 'map("${1:n}", "${2:lhs}", ${3:rhs}, { desc = "${4:desc}" })',
	},
	rust = {
		test = "#[test]\nfn ${1:name}() {\n\t${0}\n}",
	},
	go = {
		err = "if err != nil {\n\treturn ${1:err}\n}",
	},
	python = {
		main = 'if __name__ == "__main__":\n\t${0}',
	},
	javascript = {
		fn = "function ${1:name}(${2:args}) {\n\t${0}\n}",
		afn = "const ${1:name} = (${2:args}) => {\n\t${0}\n}",
	},
	typescript = {
		fn = "function ${1:name}(${2:args}): ${3:void} {\n\t${0}\n}",
		afn = "const ${1:name} = (${2:args}): ${3:void} => {\n\t${0}\n}",
	},
	php = {
		route = "Route::get('/${1:path}', [${2:Controller}::class, '${3:method}']);",
	},
	blade = {
		forelse = "@forelse (\\$${1:items} as \\$${2:item})\n\t${0}\n@empty\n@endforelse",
	},
}

local function snippet_body(trigger)
	local ft = vim.bo.filetype
	local by_ft = snippets[ft] or snippets[ft:gsub("react$", "")]
	return by_ft and by_ft[trigger]
end

map("i", "<C-k>", function()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local trigger = line:sub(1, col):match("([%w_]+)$")
	local body = trigger and snippet_body(trigger)
	if not body then
		return
	end

	vim.api.nvim_buf_set_text(0, row - 1, col - #trigger, row - 1, col, {})
	vim.api.nvim_win_set_cursor(0, { row, col - #trigger })
	vim.snippet.expand(body)
end, { desc = "Expand snippet trigger" })
