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
		"templ",
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

-- fff.nvim: file finder + live grep (replaces snacks picker for files/grep).
-- The native search binary is built on install via the PackChanged autocmd
-- in lua/plugins/pack.lua.
require("fff").setup({
	layout = {
		height = 0.8,
		width = 0.8,
		prompt_position = "bottom",
		preview_position = "right",
		preview_size = 0.5,
	},
})

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

-- Session restore: persistence.nvim auto-saves the session on exit and
-- restores it when nvim is started without file arguments.
require("persistence").setup({
	need = 1,
	branch = true,
})
vim.api.nvim_create_autocmd("StdinReadPre", {
	group = vim.api.nvim_create_augroup("persistence_restore", { clear = true }),
	callback = function()
		vim.g.started_stdin = true
	end,
})
vim.api.nvim_create_autocmd("VimEnter", {
	group = "persistence_restore",
	callback = function()
		-- Only auto-restore when nvim was opened with no file/buffer arguments.
		if vim.fn.argc() == 0 and not vim.g.started_stdin then
			require("persistence").load()
		end
	end,
})
-- The snacks explorer opens as a real vertical split (sidebar preset,
-- position = right). If it's open when the session is saved, persistence
-- captures it as a split with an empty buffer that reappears on restore.
-- `picker:close()` defers the actual close to `vim.schedule`, which runs
-- AFTER persistence's `mks!`, so we must close the explorer windows
-- synchronously here instead.
vim.api.nvim_create_autocmd("User", {
	group = "persistence_restore",
	pattern = "PersistenceSavePre",
	callback = function()
		-- Ask any open explorer picker to close first (tears down state).
		for _, picker in ipairs(require("snacks").picker.get({ source = "explorer" })) do
			picker:close()
		end
		-- Then synchronously quit any leftover snacks picker/explorer windows so
		-- they are not captured by `mksession`. Detect snacks windows either by
		-- the `snacks_win` window marker snacks sets on every window it creates,
		-- or by the buffer filetype as a fallback. Also close empty placeholder
		-- split windows snacks leaves behind (no name, no filetype, unmodified,
		-- empty), but never close the last remaining window.
		local wins = vim.api.nvim_tabpage_list_wins(0)
		for _, win in ipairs(wins) do
			if not vim.api.nvim_win_is_valid(win) then
				goto continue
			end
			local buf = vim.api.nvim_win_get_buf(win)
			local ok, ft = pcall(function() return vim.bo[buf].filetype end)
			local is_snacks_ft = ok and (ft == "snacks_picker_list"
				or ft == "snacks_picker_input"
				or ft == "snacks_picker_preview"
				or ft == "snacks_win")
			local is_snacks_win = vim.w[win] ~= nil and vim.w[win].snacks_win ~= nil
			local is_empty_placeholder = ok
				and ft == ""
				and vim.bo[buf].buftype == ""
				and not vim.bo[buf].modified
				and vim.api.nvim_buf_get_name(buf) == ""
				and vim.api.nvim_buf_line_count(buf) <= 1
			if (is_snacks_ft or is_snacks_win or is_empty_placeholder)
				and #vim.api.nvim_tabpage_list_wins(0) > 1
			then
				pcall(vim.api.nvim_win_close, win, true)
			end
			::continue::
		end
	end,
})
-- Session restore loads buffers via `badd`, which does not trigger filetype
-- detection, so the FileType autocommand that starts Treesitter never fires
-- and syntax highlighting is missing on restored buffers. Force filetype
-- detection on every loaded buffer after a session loads; the existing
-- FileType autocmd then starts Treesitter automatically.
vim.api.nvim_create_autocmd("User", {
	group = "persistence_restore",
	pattern = "PersistenceLoadPost",
	callback = function()
		vim.schedule(function()
			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
					if vim.bo[bufnr].filetype == "" then
						vim.api.nvim_buf_call(bufnr, function()
							vim.cmd("filetype detect")
						end)
					end
					-- Ensure a highlighter is running even if filetype was already set
					-- without firing FileType (e.g. restored buffer that was visited).
					if vim.bo[bufnr].filetype ~= "" and not vim.treesitter.highlighter.active[bufnr] then
						pcall(vim.treesitter.start, bufnr)
					end
				end
			end
		end)
	end,
})
vim.keymap.set("n", "<leader>qs", function()
	require("persistence").load()
end, { desc = "Restore session for cwd" })
vim.keymap.set("n", "<leader>qS", function()
	require("persistence").select()
end, { desc = "Select session" })
vim.keymap.set("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, { desc = "Restore last session" })
vim.keymap.set("n", "<leader>qD", function()
	require("persistence").stop()
end, { desc = "Stop session save on exit" })

-- Rust: rustaceanvim (runnables, expand macro, debug adapter wiring) +
-- crates.nvim (Cargo.toml dependency management). rustaceanvim is a filetype
-- plugin that owns rust-analyzer startup, so the rust-analyzer server settings
-- live here (in vim.g.rustaceanvim) rather than in lua/config/lsp.lua, and
-- "rust_analyzer" is intentionally absent from vim.lsp.enable().
--
-- Use a function so capabilities are read lazily from config.completion (which
-- loads after plugins in init.lua) at the moment rust-analyzer first starts.
vim.g.rustaceanvim = function()
	local capabilities =
		vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), require("config.completion").capabilities)
	return {
		tools = {
			hover_actions = { replace_builtin_hover = true },
		},
		server = {
			capabilities = capabilities,
			default_settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
						loadOutDirsFromCheck = true,
						runBuildScripts = true,
					},
					check = {
						allFeatures = true,
						command = "clippy",
						extraArgs = { "--no-deps" },
					},
					procMacro = {
						enable = true,
						ignored = {
							leptos_macro = { "component" },
						},
					},
				},
			},
		},
		-- rustaceanvim autoloads nvim-dap configurations for Rust when the LSP
		-- client attaches. Install a debug adapter (codelldb recommended) via
		-- `brew install codelldb` (macOS) or your distro's package manager and
		-- rustaceanvim will auto-detect it; use :RustLsp debuggables or <leader>rd.
		dap = {},
	}
end

-- crates.nvim: Cargo.toml dependency management via an in-process LSP that
-- blink picks up through its `lsp` source (no cmp source registration needed).
require("crates").setup({
	completion = { cmp = { enabled = false } },
	lsp = {
		enabled = true,
		actions = true,
		completion = true,
		hover = true,
	},
})

local rust_augroup = vim.api.nvim_create_augroup("RustConfig", { clear = true })

-- rustaceanvim commands for Rust buffers. `K` is overridden to hover actions
-- via tools.hover_actions.replace_builtin_hover above; the rest are explicit.
vim.api.nvim_create_autocmd("FileType", {
	group = rust_augroup,
	pattern = "rust",
	callback = function(args)
		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
		end
		map("<leader>rn", function() vim.cmd.RustLsp("runnables") end, "Rust runnables")
		map("<leader>rd", function() vim.cmd.RustLsp("debuggables") end, "Rust debuggables")
		map("<leader>re", function() vim.cmd.RustLsp("expandMacro") end, "Expand macro")
		map("<leader>ro", function() vim.cmd.RustLsp("openExternalDocs") end, "Open external docs")
		map("<leader>rj", function() vim.cmd.RustLsp({ "moveItem", "down" }) end, "Move item down")
		map("<leader>rk", function() vim.cmd.RustLsp({ "moveItem", "up" }) end, "Move item up")
	end,
})

-- crates.nvim commands for Cargo.toml buffers (toml filetype filtered to the
-- Cargo.toml filename). The global LspAttach autocmd in lua/config/lsp.lua
-- already wires <leader>ca code actions for the crates in-process LSP.
vim.api.nvim_create_autocmd("FileType", {
	group = rust_augroup,
	pattern = "toml",
	callback = function(args)
		if not vim.api.nvim_buf_get_name(args.buf):match("Cargo%.toml$") then
			return
		end
		local map = function(lhs, action, desc)
			vim.keymap.set("n", lhs, function() require("crates")[action]() end, { buffer = args.buf, desc = desc })
		end
		map("<leader>rcu", "update_crate", "Update crate")
		map("<leader>rcU", "upgrade_crate", "Upgrade crate")
		map("<leader>rca", "update_all_crates", "Update all crates")
		map("<leader>rcA", "upgrade_all_crates", "Upgrade all crates")
		map("<leader>rcp", "show_popup", "Show crate popup")
		map("<leader>rcr", "reload", "Reload crates")
	end,
})

-- DAP: nvim-dap + nvim-dap-ui. `<leader>d`/`<leader>D` are taken (delete to
-- system clipboard), so debug controls live under the free `<leader>;` prefix.
-- rustaceanvim autoloads Rust launch configs on LSP attach; DAP UI opens/closes
-- automatically when a session starts/ends.
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

vim.keymap.set("n", "<leader>;b", function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>;B", function() dap.clear_breakpoints() end, { desc = "Clear Breakpoints" })
vim.keymap.set("n", "<leader>;c", function() dap.continue() end, { desc = "DAP Continue" })
vim.keymap.set("n", "<leader>;s", function() dap.step_over() end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>;i", function() dap.step_into() end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>;o", function() dap.step_out() end, { desc = "Step Out" })
vim.keymap.set("n", "<leader>;t", function() dapui.toggle() end, { desc = "Toggle DAP UI" })
