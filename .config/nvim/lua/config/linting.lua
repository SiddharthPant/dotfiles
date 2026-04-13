local augroup = require("config.autocmds").group
local lint = require("lint")

vim.keymap.set("n", "<leader>cL", function()
	lint.try_lint()
end, { desc = "Code Lint" })

lint.linters_by_ft = {
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	vue = { "eslint_d" },
	svelte = { "eslint_d" },
	json = {},
	jsonc = {},
	lua = { "luacheck" },
	python = { "ruff" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	zsh = { "shellcheck" },
	c = { "cpplint" },
	cpp = { "cpplint" },
	go = { "golangcilint" },
	rust = {}, -- rust-analyzer handles linting via clippy
}

local function debounce(ms, fn)
	---@type uv.uv_timer_t
	local timer = assert(vim.uv.new_timer())
	return function(...)
		local argv = { ... }
		timer:start(ms, 0, function()
			timer:stop()
			vim.schedule(function()
				fn(unpack(argv))
			end)
		end)
	end
end

-- Run linting after reads, insert exits, and writes with a small debounce.
vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "BufWritePost" }, {
	group = augroup,
	callback = debounce(100, function(args)
		if not vim.api.nvim_buf_is_valid(args.buf) or not vim.api.nvim_buf_is_loaded(args.buf) then
			return
		end
		if not vim.bo[args.buf].buflisted then
			return
		end
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		if vim.api.nvim_buf_get_name(args.buf) == "" then
			return
		end
		lint.try_lint()
	end),
})
