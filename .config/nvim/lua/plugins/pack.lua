vim.pack.add({
	"https://www.github.com/catppuccin/nvim",
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/folke/snacks.nvim",
	"https://www.github.com/echasnovski/mini.nvim", -- Only for surround + clue
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
	-- LazyGit integration
	"https://github.com/kdheepak/lazygit.nvim",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end

packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("snacks.nvim")
packadd("mini.nvim") -- surround + clue + jump2d + statusline
packadd("bufferline.nvim")
packadd("undotree")
packadd("codediff.nvim")
packadd("lazygit.nvim")
packadd("nvim-lspconfig")
packadd("lazydev.nvim")
packadd("conform.nvim")
packadd("nvim-lint")
packadd("blink.cmp")
packadd("nvim") -- catppuccin theme
