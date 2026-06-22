-- rustaceanvim owns rust-analyzer startup and Rust DAP wiring, so
-- rust_analyzer intentionally stays out of lua/config/lsp.lua.
vim.g.rustaceanvim = function()
	local capabilities = vim.tbl_deep_extend(
		"force",
		vim.lsp.protocol.make_client_capabilities(),
		require("config.completion").capabilities
	)

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
		dap = {},
	}
end

require("crates").setup({
	completion = { cmp = { enabled = false } },
	lsp = {
		enabled = true,
		actions = true,
		completion = true,
		hover = true,
	},
})

local rust_group = vim.api.nvim_create_augroup("RustConfig", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = rust_group,
	pattern = "rust",
	callback = function(args)
		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
		end

		map("<leader>rn", function()
			vim.cmd.RustLsp("runnables")
		end, "Rust runnables")
		map("<leader>rd", function()
			vim.cmd.RustLsp("debuggables")
		end, "Rust debuggables")
		map("<leader>re", function()
			vim.cmd.RustLsp("expandMacro")
		end, "Expand macro")
		map("<leader>ro", function()
			vim.cmd.RustLsp("openExternalDocs")
		end, "Open external docs")
		map("<leader>rj", function()
			vim.cmd.RustLsp({ "moveItem", "down" })
		end, "Move item down")
		map("<leader>rk", function()
			vim.cmd.RustLsp({ "moveItem", "up" })
		end, "Move item up")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = rust_group,
	pattern = "toml",
	callback = function(args)
		if not vim.api.nvim_buf_get_name(args.buf):match("Cargo%.toml$") then
			return
		end

		local map = function(lhs, action, desc)
			vim.keymap.set("n", lhs, function()
				require("crates")[action]()
			end, { buffer = args.buf, desc = desc })
		end

		map("<leader>rcu", "update_crate", "Update crate")
		map("<leader>rcU", "upgrade_crate", "Upgrade crate")
		map("<leader>rca", "update_all_crates", "Update all crates")
		map("<leader>rcA", "upgrade_all_crates", "Upgrade all crates")
		map("<leader>rcp", "show_popup", "Show crate popup")
		map("<leader>rcr", "reload", "Reload crates")
	end,
})

local dap = require("dap")
local dapui = require("dapui")

local function notify_toggle(title, enabled)
	require("snacks").notify(("%s %s"):format(title, enabled and "enabled" or "disabled"), {
		title = title,
		level = "info",
	})
end

local function dapui_is_open()
	for _, layout in ipairs(require("dapui.windows").layouts) do
		if layout:is_open() then
			return true
		end
	end
	return false
end

dapui.setup()

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

vim.keymap.set("n", "<leader>db", function()
	dap.toggle_breakpoint()
end, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.clear_breakpoints()
end, { desc = "Clear breakpoints" })
vim.keymap.set("n", "<leader>dc", function()
	dap.continue()
end, { desc = "DAP continue" })
vim.keymap.set("n", "<leader>ds", function()
	dap.step_over()
end, { desc = "Step over" })
vim.keymap.set("n", "<leader>di", function()
	dap.step_into()
end, { desc = "Step into" })
vim.keymap.set("n", "<leader>do", function()
	dap.step_out()
end, { desc = "Step out" })
vim.keymap.set("n", "<leader>dt", function()
	dapui.toggle()
	notify_toggle("DAP UI", dapui_is_open())
end, { desc = "Toggle DAP UI" })
