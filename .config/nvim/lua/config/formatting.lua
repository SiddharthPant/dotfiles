local util = require("conform.util")

local web_formatter_names = {
	"vite_plus_fmt",
	"biome",
	"dprint",
	"prettierd",
	"prettier",
	"oxfmt",
	stop_after_first = true,
}

local prettier_config_files = {
	".prettierrc",
	".prettierrc.json",
	".prettierrc.yml",
	".prettierrc.yaml",
	".prettierrc.json5",
	".prettierrc.js",
	".prettierrc.cjs",
	".prettierrc.mjs",
	".prettierrc.toml",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
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

local function root_with_files(ctx, files)
	return find_upward_dir(ctx.dirname, function(dir)
		for _, file in ipairs(files) do
			if vim.uv.fs_stat(vim.fs.joinpath(dir, file)) then
				return true
			end
		end
		return false
	end)
end

local function root_with_package(ctx, predicate)
	return find_upward_dir(ctx.dirname, function(dir)
		local package_json = vim.fs.joinpath(dir, "package.json")
		if not vim.uv.fs_stat(package_json) then
			return false
		end
		local pkg = read_json(package_json)
		return pkg and predicate(pkg) or false
	end)
end

local function prettier_root(_, ctx)
	return root_with_files(ctx, prettier_config_files) or root_with_package(ctx, function(pkg)
		return pkg.prettier ~= nil or has_dependency(pkg, { "prettier", "prettierd" })
	end)
end

local function biome_root(_, ctx)
	return root_with_files(ctx, { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" })
		or root_with_package(ctx, function(pkg)
			return has_dependency(pkg, { "@biomejs/biome", "biome" })
		end)
end

local function vite_plus_root(_, ctx)
	return root_with_package(ctx, function(pkg)
		if has_dependency(pkg, { "vite-plus" }) then
			return true
		end
		local vite = (pkg.dependencies and pkg.dependencies.vite) or (pkg.devDependencies and pkg.devDependencies.vite)
		return type(vite) == "string" and vite:find("vite%-plus", 1, false) ~= nil
	end)
end

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({
		timeout_ms = 2000,
	})
end, { desc = "Code Format" })

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
		javascript = web_formatter_names,
		javascriptreact = web_formatter_names,
		typescript = web_formatter_names,
		typescriptreact = web_formatter_names,
		vue = web_formatter_names,
		svelte = web_formatter_names,
		css = web_formatter_names,
		scss = web_formatter_names,
		less = web_formatter_names,
		html = web_formatter_names,
		json = web_formatter_names,
		jsonc = web_formatter_names,
		markdown = web_formatter_names,
		lua = { "stylua" },
		python = { "ruff_format" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		go = { "gofumpt" },
	},
	formatters = {
		vite_plus_fmt = {
			command = util.from_node_modules("vp"),
			args = { "fmt", "--stdin-filepath", "$FILENAME" },
			stdin = true,
			cwd = vite_plus_root,
			require_cwd = true,
		},
		biome = {
			cwd = biome_root,
			require_cwd = true,
		},
		dprint = {
			require_cwd = true,
		},
		prettierd = {
			cwd = prettier_root,
			require_cwd = true,
		},
		prettier = {
			cwd = prettier_root,
			require_cwd = true,
		},
		oxfmt = {
			require_cwd = true,
		},
	},
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
