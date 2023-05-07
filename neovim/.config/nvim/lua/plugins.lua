-- This file can be loaded by calling `lua require('plugins')` from your init.vim

return require('packer').startup(function(use)
    -- Packer can manage itself
    use {
        'wbthomason/packer.nvim',
        'folke/tokyonight.nvim',
        'nvim-treesitter/nvim-treesitter',
        'sheerun/vim-polyglot',
        'nvim-lua/completion-nvim',
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig',
        'mfussenegger/nvim-lint',
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        'jremmen/vim-ripgrep',
    }
    use { 'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/plenary.nvim'}} }
    use {
        'lewis6991/gitsigns.nvim',
        tag = 'release',
        config = function()
            require('gitsigns').setup()
        end
    }
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use {
        'windwp/nvim-autopairs',
        config = function()
            require("nvim-autopairs").setup {}
        end
    }
end)
