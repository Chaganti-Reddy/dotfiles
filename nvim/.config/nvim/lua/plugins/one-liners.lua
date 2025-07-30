return {
    { -- This helps with php/html for indentation
        'captbaritone/better-indent-support-for-php-with-html',
    },
    { -- This helps with ssh tunneling and copying to clipboard
        'ojroques/vim-oscyank',
    },
    { -- This generates docblocks
        'kkoomen/vim-doge',
        build = ':call doge#install()'
    },
    { -- Git plugin
        'tpope/vim-fugitive',
    },
    { -- Show historical versions of the file locally
        'mbbill/undotree',
    },
    { -- Show CSS Colors
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup({})
        end
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },
}
