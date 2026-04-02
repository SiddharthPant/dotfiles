local augroup = require("config.autocmds").group
local lint = require("lint")
local oxlint = require("lint.linters.oxlint")

local web_filetypes = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	vue = true,
	svelte = true,
	json = true,
	jsonc = true,
}

local eslint_filetypes = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	vue = true,
	svelte = true,
}

local biome_config_files = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
local oxlint_config_files = { ".oxlintrc.json", ".oxlintrc.jsonc" }
local eslint_config_files = {
	"eslint.config.js",
	"eslint.config.cjs",
	"eslint.config.mjs",
	"eslint.config.ts",
	"eslint.config.mts",
	"eslint.config.cts",
	".eslintrc",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.mjs",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
}

local function find_upward_dir(start_dir, predicate)
	local dir = start_dir
	while dir and dir ~= "" do
		if predicate(dir) then
			return dir
		end
		local parent = vim.fs.dirname(dir)
		if not parent or parent == dir then
			return nil
		end
		dir = parent
	end
	return nil
end

local function read_json(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		return nil
	end
	local decoded, data = pcall(vim.json.decode, table.concat(lines, "\n"))
	return decoded and data or nil
end

local function has_dependency(pkg, names)
	for _, field in ipairs({ "dependencies", "devDependencies", "peerDependencies", "optionalDependencies" }) do
		local deps = pkg[field]
		if deps then
			for _, name in ipairs(names) do
				if deps[name] then
					return true
				end
			end
		end
	end
	return false
end

local function root_with_files(bufnr, files)
	local path = vim.api.nvim_buf_get_name(bufnr)
	if path == "" then
		return nil
	end
	return find_upward_dir(vim.fs.dirname(path), function(dir)
		for _, file in ipairs(files) do
			if vim.uv.fs_stat(vim.fs.joinpath(dir, file)) then
				return true
			end
		end
		return false
	end)
end

local function root_with_package(bufnr, predicate)
	local path = vim.api.nvim_buf_get_name(bufnr)
	if path == "" then
		return nil
	end
	return find_upward_dir(vim.fs.dirname(path), function(dir)
		local package_json = vim.fs.joinpath(dir, "package.json")
		if not vim.uv.fs_stat(package_json) then
			return false
		end
		local pkg = read_json(package_json)
		return pkg and predicate(pkg) or false
	end)
end

local function vite_plus_root(bufnr)
	return root_with_package(bufnr, function(pkg)
		if has_dependency(pkg, { "vite-plus" }) then
			return true
		end
		local vite = (pkg.dependencies and pkg.dependencies.vite) or (pkg.devDependencies and pkg.devDependencies.vite)
		return type(vite) == "string" and vite:find("vite%-plus", 1, false) ~= nil
	end)
end

local function biome_root(bufnr)
	return root_with_files(bufnr, biome_config_files) or root_with_package(bufnr, function(pkg)
		return has_dependency(pkg, { "@biomejs/biome", "biome" })
	end)
end

local function eslint_root(bufnr)
	return root_with_files(bufnr, eslint_config_files) or root_with_package(bufnr, function(pkg)
		return pkg.eslintConfig ~= nil or has_dependency(pkg, { "eslint", "eslint_d" })
	end)
end

local function oxlint_root(bufnr)
	return root_with_files(bufnr, oxlint_config_files) or root_with_package(bufnr, function(pkg)
		return has_dependency(pkg, { "oxlint", "oxc" })
	end)
end

local function lint_names(bufnr)
	local ft = vim.bo[bufnr].filetype
	if web_filetypes[ft] then
		local root = vite_plus_root(bufnr)
		if root then
			return { "vp_lint" }, root
		end

		root = biome_root(bufnr)
		if root then
			return { "biomejs" }, root
		end

		if eslint_filetypes[ft] then
			root = eslint_root(bufnr)
			if root then
				local package_json = vim.fs.joinpath(root, "package.json")
				local pkg = vim.uv.fs_stat(package_json) and read_json(package_json) or nil
				if pkg and has_dependency(pkg, { "eslint_d" }) then
					return { "eslint_d" }, root
				end
				return { "eslint" }, root
			end
		end

		root = oxlint_root(bufnr)
		if root then
			return { "oxlint" }, root
		end

		return {}, nil
	end
	return lint._resolve_linter_by_ft(ft), nil
end

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
	local names, cwd = lint_names(bufnr)
	if #names == 0 then
		return
	end

	vim.api.nvim_buf_call(bufnr, function()
		lint.try_lint(names, { cwd = cwd })
	end)
end

vim.keymap.set("n", "<leader>cL", function()
	lint_buffer(vim.api.nvim_get_current_buf())
end, { desc = "Code Lint" })

lint.linters.vp_lint = function()
	local root = vite_plus_root(vim.api.nvim_get_current_buf())
	local binary = vim.fn.has("win32") == 1 and "vp.cmd" or "vp"
	local cmd = binary
	if root then
		local local_binary = vim.fs.joinpath(root, "node_modules", ".bin", binary)
		if vim.uv.fs_stat(local_binary) then
			cmd = local_binary
		end
	end

	---@type lint.Linter
	return {
		name = "vp_lint",
		cmd = cmd,
		stdin = false,
		append_fname = true,
		args = { "lint", "--format", "github" },
		stream = "stdout",
		ignore_exitcode = true,
		parser = oxlint.parser,
	}
end

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
