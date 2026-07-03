local augroup = require("config.autocmds").group
local lint = require("lint")

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
	json = {},
	jsonc = {},
	lua = {},
	python = { "ruff" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	zsh = { "shellcheck" },
	c = { "cpplint" },
	cpp = { "cpplint" },
	go = { "golangcilint" },
	rust = {}, -- rust-analyzer handles linting via clippy
	toml = {},
	sql = { "sqlfluff" },
}

local lint_timers = {}

local function lint_buffer(args)
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
	if vim.bo[args.buf].filetype == "go" and args.event ~= "BufWritePost" then
		return
	end

	vim.api.nvim_buf_call(args.buf, function()
		lint.try_lint()
	end)
end

local function debounce_buffer(ms, fn)
	---@type uv.uv_timer_t
	return function(args)
		lint_timers[args.buf] = lint_timers[args.buf] or assert(vim.uv.new_timer())
		local timer = lint_timers[args.buf]

		timer:start(ms, 0, function()
			timer:stop()
			vim.schedule(function()
				fn(args)
			end)
		end)
	end
end

-- Run linting after reads, buffer entry, insert exits, and writes with a small debounce.
-- Keep golangci-lint save-only; gopls already covers fast edit-time feedback.
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "InsertLeave", "BufWritePost" }, {
	group = augroup,
	callback = debounce_buffer(100, lint_buffer),
})

vim.api.nvim_create_autocmd("BufWipeout", {
	group = augroup,
	callback = function(args)
		local timer = lint_timers[args.buf]
		if timer then
			timer:stop()
			timer:close()
			lint_timers[args.buf] = nil
		end
	end,
})
