local augroup = require("config.autocmds").group
local lsp_capabilities = vim.tbl_deep_extend("force", require("config.completion").capabilities, {
	workspace = {
		fileOperations = {
			didRename = true,
			willRename = true,
		},
	},
})

vim.lsp.inlay_hint.enable(true)
vim.lsp.codelens.enable(true)
vim.lsp.inline_completion.enable(true)

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
		source = true,
		header = "",
		prefix = "",
		focusable = true,
		style = "minimal",
	},
})

local function enable_lsp_buffer_features(client, bufnr)
	if client:supports_method("textDocument/linkedEditingRange") then
		vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
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

	map("n", "<leader>cD", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, "Line Diagnostics")
	map("n", "<leader>cd", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, "Cursor Diagnostics")

	-- LSP list pickers (using snacks.nvim instead of fzf-lua)
	map("n", "<leader>ld", function()
		require("snacks").picker.lsp_definitions()
	end, "LSP definitions")
	map("n", "<leader>lr", function()
		require("snacks").picker.lsp_references()
	end, "LSP references")
	map("n", "<leader>lt", function()
		require("snacks").picker.lsp_type_definitions()
	end, "LSP type definitions")
	map("n", "<leader>ls", function()
		require("snacks").picker.lsp_symbols()
	end, "LSP document symbols")
	map("n", "<leader>lw", function()
		require("snacks").picker.lsp_workspace_symbols()
	end, "LSP workspace symbols")
	map("n", "<leader>li", function()
		require("snacks").picker.lsp_implementations()
	end, "LSP implementations")

	if client:supports_method("textDocument/codeAction", bufnr) then
		map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
		map("n", "<leader>cA", function()
			vim.lsp.buf.code_action({
				context = { only = { "source" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
		end, "Source Action")
		map("n", "<leader>co", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				require("conform").format({ bufnr = bufnr, timeout_ms = 2000 })
			end, 50)
		end, "Organize Imports")
	end

	if client:supports_method("textDocument/rename", bufnr) then
		map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
	end

	if client:supports_method("textDocument/inlayHint") then
		map("n", "<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle Inlay Hints")
	end

	if client:supports_method("textDocument/codeLens") then
		map("n", "<leader>tC", function()
			vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle CodeLens")
	end

	if client:supports_method("textDocument/inlineCompletion") then
		map("n", "<leader>ti", function()
			vim.lsp.inline_completion.enable(
				not vim.lsp.inline_completion.is_enabled({ bufnr = bufnr }),
				{ bufnr = bufnr }
			)
		end, "Toggle Inline Completion")
	end

	map("n", "<leader>lR", function()
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			c:stop(true)
		end
		vim.defer_fn(function()
			vim.cmd("edit")
		end, 100)
	end, "Restart LSP")

	enable_lsp_buffer_features(client, bufnr)
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>cq", function()
	if vim.tbl_isempty(vim.diagnostic.get(0)) then
		require("snacks").notify("No diagnostics available", {
			title = "LSP Diagnostics",
			level = "info",
		})
		return
	end

	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>cl", function()
	require("snacks").picker.lsp_config()
end, { desc = "LSP Config" })
vim.keymap.set("n", "<leader>cR", function()
	require("snacks").rename.rename_file()
end, { desc = "Rename File" })

vim.lsp.config("*", {
	capabilities = lsp_capabilities,
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				checkThirdParty = false,
			},
			codeLens = {
				enable = true,
			},
			completion = {
				callSnippet = "Replace",
			},
			diagnostics = { globals = { "vim" } },
			doc = {
				privateName = { "^_" },
			},
			hint = {
				enable = true,
				setType = false,
				paramType = true,
				paramName = "Disable",
				semicolon = "Disable",
				arrayIndex = "Disable",
			},
			telemetry = { enable = false },
		},
	},
})
vim.lsp.config("pyright", {})
vim.lsp.config("bashls", {})
vim.lsp.config("jsonls", {
	before_init = function(_, config)
		config.settings = config.settings or {}
		config.settings.json = config.settings.json or {}
		config.settings.json.schemas = config.settings.json.schemas or {}
		vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
	end,
	settings = {
		json = {
			format = { enable = true },
			validate = { enable = true },
		},
	},
})
vim.lsp.config("ts_ls", {})
vim.lsp.config("gopls", {
	settings = {
		gopls = {
			usePlaceholders = true,
			completionBudget = "250ms",
			matcher = "Fuzzy",
			completeFunctionCalls = true,
			experimentalPostfixCompletions = true,
			semanticTokens = true,
		},
	},
})
vim.lsp.config("html", {
	filetypes = { "html", "templ", "htmldjango" },
	init_options = {
		provideFormatter = false,
		embeddedLanguages = { css = true, javascript = true },
		configurationSection = { "html", "css", "javascript" },
	},
})
vim.lsp.config("clangd", {})
vim.lsp.config("taplo", {})
vim.lsp.config("templ", {})

-- rust_analyzer is started by rustaceanvim (see lua/plugins/lang.lua),
-- which owns its server settings and DAP wiring. Do not add it here.

-- Note: LSP servers should be installed manually via your package manager
-- Example: npm install -g typescript-language-server pyright bash-language-server
-- Example: brew install lua-language-server gopls clangd rust-analyzer
-- Example: go install github.com/a-h/templ/cmd/templ@latest
vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"jsonls",
	"ts_ls",
	"gopls",
	"html",
	"clangd",
	"taplo",
	"templ",
})
