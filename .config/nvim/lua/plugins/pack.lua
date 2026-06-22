local function packadd(name)
	vim.cmd("packadd " .. name)
end

local function notify_pack_hook(message, level)
	vim.schedule(function()
		local ok, snacks = pcall(require, "snacks")
		if ok then
			snacks.notify(message, {
				title = "vim.pack",
				level = level or "warn",
			})
		else
			vim.notify(message, vim.log.levels[(level or "warn"):upper()] or vim.log.levels.WARN)
		end
	end)
end

local function run_pack_job(name, cmd, opts)
	local result = vim.system(cmd, opts):wait()
	if result.code == 0 then
		return
	end

	local stderr = vim.trim(result.stderr or "")
	notify_pack_hook(name .. " build hook failed" .. (stderr ~= "" and ": " .. stderr or ""), "error")
end

local function on_pack_changed(ev)
	local name, kind = ev.data.spec.name, ev.data.kind
	if kind ~= "install" and kind ~= "update" then
		return
	end

	if name == "fff.nvim" then
		if not ev.data.active then
			packadd("fff.nvim")
		end
		require("fff.download").download_or_build_binary()
	elseif name == "LuaSnip" and vim.fn.executable("make") == 1 then
		run_pack_job("LuaSnip", { "make", "install_jsregexp" }, { cwd = ev.data.path })
	elseif name == "markdown-preview.nvim" then
		if not ev.data.active then
			packadd("markdown-preview.nvim")
		end
		if vim.fn.exists("*mkdp#util#install") == 1 then
			vim.fn["mkdp#util#install"]()
		end
	end
end

vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("PackBuildHooks", { clear = true }),
	callback = on_pack_changed,
})

vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/folke/snacks.nvim",
	"https://github.com/dmtrKovalenko/fff.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/b0o/SchemaStore.nvim",
	"https://www.github.com/echasnovski/mini.nvim", -- pairs + surround + clue
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/mbbill/undotree",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},
	-- Language Server Protocols (Native - no mason)
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	-- Advanced diff view
	"https://github.com/esmuellert/codediff.nvim",
	-- AI inline completions
	"https://github.com/supermaven-inc/supermaven-nvim",
	-- Rust: rustaceanvim (runnables, expand macro, debug adapter wiring). It
	-- manages rust-analyzer itself, so rust_analyzer is NOT in vim.lsp.enable().
	"https://github.com/mrcjkb/rustaceanvim",
	-- Rust: Cargo.toml dependency management (versions, features, code actions)
	{ src = "https://github.com/saecki/crates.nvim", version = "stable" },
	-- Debug Adapter Protocol: debugging UI (rustaceanvim autoloads Rust configs)
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/nvim-neotest/nvim-nio",
	-- Markdown preview in browser
	"https://github.com/iamcco/markdown-preview.nvim",
	-- Markdown rendering inside Neovim
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	-- Tmux pane/window navigation
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/folke/persistence.nvim",
})

packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("snacks.nvim")
packadd("fff.nvim")
packadd("grug-far.nvim")
packadd("flash.nvim")
packadd("LuaSnip")
packadd("friendly-snippets")
packadd("SchemaStore.nvim")
packadd("mini.nvim") -- pairs + surround + clue + statusline
packadd("bufferline.nvim")
packadd("undotree")
packadd("codediff.nvim")
packadd("nvim-lspconfig")
packadd("lazydev.nvim")
packadd("conform.nvim")
packadd("nvim-lint")
packadd("blink.cmp")
packadd("supermaven-nvim")
packadd("rustaceanvim")
packadd("crates.nvim")
packadd("nvim-nio")
packadd("nvim-dap")
packadd("nvim-dap-ui")
packadd("markdown-preview.nvim")
packadd("render-markdown.nvim")
packadd("vim-tmux-navigator")
packadd("catppuccin")
packadd("persistence.nvim")
