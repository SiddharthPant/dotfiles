local augroup = require("config.autocmds").group
local lint = require("lint")

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

local function lint_buffer(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return
	end
	if not vim.bo[bufnr].buflisted then
		return
	end
	if vim.bo[bufnr].buftype ~= "" then
		return
	end
	if vim.api.nvim_buf_get_name(bufnr) == "" then
		return
	end

	vim.api.nvim_buf_call(bufnr, function()
		lint.try_lint()
	end)
end

vim.keymap.set("n", "<leader>cL", function()
	lint.try_lint()
end, { desc = "Code Lint" })

lint.linters_by_ft = {
	javascript = { "oxlint" },
	javascriptreact = { "oxlint" },
	typescript = { "oxlint" },
	typescriptreact = { "oxlint" },
	vue = { "oxlint" },
	svelte = { "oxlint" },
	json = { "oxlint" },
	jsonc = { "oxlint" },
	lua = { "luacheck" },
	python = { "ruff" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	zsh = { "shellcheck" },
	c = { "cpplint" },
	cpp = { "cpplint" },
	go = { "golangcilint" },
}

-- Run linting after reads, insert exits, and writes with a small debounce.
vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "BufWritePost" }, {
	group = augroup,
	callback = debounce(100, function(args)
		lint_buffer(args.buf)
	end),
})
