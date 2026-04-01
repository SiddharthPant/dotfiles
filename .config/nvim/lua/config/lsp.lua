local augroup = require("config.autocmds").group
local folds = require("config.folds")

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

local function enable_lsp_buffer_features(client, bufnr)
	folds.refresh(bufnr)

	if client:supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	if client:supports_method("textDocument/codeLens") then
		vim.lsp.codelens.enable(true, { bufnr = bufnr })
		if not vim.b[bufnr].lsp_codelens_refresh then
			vim.b[bufnr].lsp_codelens_refresh = true
			vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
				group = augroup,
				buffer = bufnr,
				callback = function()
					if vim.lsp.codelens.is_enabled({ bufnr = bufnr }) then
						pcall(vim.lsp.codelens.refresh, { bufnr = bufnr })
					end
				end,
			})
		end
		pcall(vim.lsp.codelens.refresh, { bufnr = bufnr })
	end

	if client:supports_method("textDocument/linkedEditingRange") then
		vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
	end

	if client:supports_method("textDocument/inlineCompletion") then
		vim.lsp.inline_completion.enable(true, { bufnr = bufnr, client_id = client.id })
	end
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
	end

	-- Neovim already provides modern defaults for: gra, grn, grr, gri, grt, gO, K
	map("n", "<leader>lv", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, "LSP definition in split")

	map("n", "<leader>lE", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, "Line diagnostics")
	map("n", "<leader>le", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, "Cursor diagnostics")

	-- LSP Pickers (using snacks.nvim instead of fzf-lua)
	map("n", "<leader>fd", function()
		require("snacks").picker.lsp_definitions()
	end, "Find definitions")
	map("n", "<leader>fr", function()
		require("snacks").picker.lsp_references()
	end, "Find references")
	map("n", "<leader>ft", function()
		require("snacks").picker.lsp_type_definitions()
	end, "Find type definitions")
	map("n", "<leader>fs", function()
		require("snacks").picker.lsp_symbols()
	end, "Find document symbols")
	map("n", "<leader>fw", function()
		require("snacks").picker.lsp_workspace_symbols()
	end, "Find workspace symbols")
	map("n", "<leader>fi", function()
		require("snacks").picker.lsp_implementations()
	end, "Find implementations")

	if client:supports_method("textDocument/codeAction", bufnr) then
		map("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				require("conform").format({ bufnr = bufnr, timeout_ms = 2000 })
			end, 50)
		end, "Organize imports")
	end

	if client:supports_method("textDocument/inlayHint") then
		map("n", "<leader>lH", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle inlay hints")
	end

	if client:supports_method("textDocument/codeLens") then
		map("n", "<leader>lC", function()
			vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle code lens")
	end

	if client:supports_method("textDocument/inlineCompletion") then
		map("n", "<leader>lI", function()
			vim.lsp.inline_completion.enable(
				not vim.lsp.inline_completion.is_enabled({ bufnr = bufnr }),
				{ bufnr = bufnr }
			)
		end, "Toggle inline completion")
	end

	enable_lsp_buffer_features(client, bufnr)
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })
vim.api.nvim_create_autocmd("LspDetach", {
	group = augroup,
	callback = function(ev)
		vim.schedule(function()
			folds.refresh(ev.buf)
		end)
	end,
})

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })

vim.keymap.set({ "n", "v" }, "<leader>lf", function()
	require("conform").format({
		timeout_ms = 2000,
	})
end, { desc = "Code format" })

vim.keymap.set("n", "<leader>ll", function()
	require("lint").try_lint()
end, { desc = "Code lint" })

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

vim.keymap.set("i", "<C-y>", function()
	if vim.lsp.inline_completion.get() then
		return ""
	end
	return "<C-y>"
end, { expr = true, desc = "Accept inline completion" })

vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

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

require("conform").setup({
	default_format_opts = {
		lsp_format = "never",
	},
	notify_no_formatters = false,
	format_on_save = function(bufnr)
		if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(bufnr) == "" then
			return
		end
		return { timeout_ms = 2000 }
	end,
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
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

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
	group = augroup,
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		lint.try_lint()
	end,
})

-- Note: LSP servers should be installed manually via your package manager
-- Example: npm install -g typescript-language-server pyright bash-language-server
-- Example: brew install lua-language-server gopls clangd
vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"ts_ls",
	"gopls",
	"clangd",
})
