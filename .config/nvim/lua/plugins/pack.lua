vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/folke/snacks.nvim",
	"https://github.com/dmtrKovalenko/fff.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/folke/flash.nvim",
	{
		src = "https://github.com/L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
	},
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/b0o/SchemaStore.nvim",
	"https://www.github.com/echasnovski/mini.nvim", -- pairs + surround + clue
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/mbbill/undotree",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
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
	-- TOML (for Cargo.toml)
	"https://github.com/tamasfe/taplo",
	-- AI inline completions
	"https://github.com/supermaven-inc/supermaven-nvim",
	-- Markdown preview in browser
	{
		src = "https://github.com/iamcco/markdown-preview.nvim",
		build = "cd app && npx --yes yarn install",
	},
	-- Markdown rendering inside Neovim
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	-- Tmux pane/window navigation
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/folke/persistence.nvim",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end

packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("snacks.nvim")
packadd("fff.nvim")
packadd("grug-far.nvim")

-- Build fff.nvim's native binary on install/update (downloads prebuilt or falls
-- back to a cargo build via the plugin's own download helper).
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("FffBuild", { clear = true }),
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "fff.nvim" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd("packadd fff.nvim")
			end
			require("fff.download").download_or_build_binary()
		end
	end,
})
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
packadd("taplo")
packadd("supermaven-nvim")
packadd("markdown-preview.nvim")
packadd("render-markdown.nvim")
packadd("vim-tmux-navigator")
packadd("catppuccin")
packadd("persistence.nvim")
