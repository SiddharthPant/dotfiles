local augroup = require("config.autocmds").group
local folds = require("config.folds")
local lsp_capabilities = vim.tbl_deep_extend("force", require("config.completion").capabilities, {
	workspace = {
		fileOperations = {
			didRename = true,
			willRename = true,
		},
	},
})

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
						pcall(vim.lsp.codelens.enable, true, { bufnr = bufnr })
					end
				end,
			})
		end
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

	map("n", "<leader>cD", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, "Line Diagnostics")
	map("n", "<leader>cd", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, "Cursor Diagnostics")

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
		map("n", "<leader>ch", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle Inlay Hints")
	end

	if client:supports_method("textDocument/codeLens") then
		map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, "Run CodeLens")
		map("n", "<leader>cC", function()
			vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle CodeLens")
	end

	if client:supports_method("textDocument/inlineCompletion") then
		map("n", "<leader>ci", function()
			vim.lsp.inline_completion.enable(
				not vim.lsp.inline_completion.is_enabled({ bufnr = bufnr }),
				{ bufnr = bufnr }
			)
		end, "Toggle Inline Completion")
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

vim.keymap.set("n", "<leader>qd", function()
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
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {})
vim.lsp.config("taplo", {})

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
				loadOutDirsFromCheck = true,
				runBuildScripts = true,
			},
			checkOnSave = true,
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
})

-- Note: LSP servers should be installed manually via your package manager
-- Example: npm install -g typescript-language-server pyright bash-language-server
-- Example: brew install lua-language-server gopls clangd rust-analyzer
vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"jsonls",
	"ts_ls",
	"gopls",
	"clangd",
	"rust_analyzer",
	"taplo",
})
