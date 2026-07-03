local M = {}

M.group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

local function rust_project_uses_askama(path)
	local cargo_toml = vim.fs.find("Cargo.toml", {
		path = vim.fs.dirname(path),
		upward = true,
	})[1]

	if not cargo_toml then
		return false
	end

	local ok, lines = pcall(vim.fn.readfile, cargo_toml, "", 1000)
	if not ok then
		return false
	end

	return table.concat(lines, "\n"):find("askama", 1, true) ~= nil
end

vim.filetype.add({
	extension = {
		askama = "htmldjango",
		templ = "templ",
	},
})

local function set_askama_template_filetype(bufnr)
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		return
	end

	local path = vim.api.nvim_buf_get_name(bufnr)
	if path:match("/templates/.*%.html$") and rust_project_uses_askama(path) then
		vim.bo[bufnr].filetype = "htmldjango"
	end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
	group = M.group,
	pattern = "*/templates/*.html",
	callback = function(args)
		set_askama_template_filetype(args.buf)
	end,
})

vim.schedule(function()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		set_askama_template_filetype(bufnr)
	end
end)

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = M.group,
	callback = function()
		vim.hl.on_yank()
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

-- wrap and linebreak on prose-like files
vim.api.nvim_create_autocmd("FileType", {
	group = M.group,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
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

return M
