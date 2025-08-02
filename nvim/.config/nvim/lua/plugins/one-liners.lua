return {
	{ -- This helps with php/html for indentation
		"captbaritone/better-indent-support-for-php-with-html",
	},
	{ -- This helps with ssh tunneling and copying to clipboard
		"ojroques/vim-oscyank",
	},
	{ -- This generates docblocks
		"kkoomen/vim-doge",
		build = ":call doge#install()",
	},
	{ -- Git plugin
		"tpope/vim-fugitive",
	},
	{ -- Show historical versions of the file locally
		"mbbill/undotree",
	},
	{ -- Show CSS Colors
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({})
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
		opts = {},
	},

	{
		"Exafunction/codeium.vim",
		event = "BufEnter",
	},
	{
		"stevearc/conform.nvim",
		event = "BufWritePre", -- uncomment for format on save
		opts = require("config.conform"),
	},

	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			-- vim.g.vimtex_view_method = "zathura"
			vim.g.vimtex_view_method = "general"
			vim.g.vimtex_syntax_enabled = 1
		end,
	},

	-- https://nvimdev.github.io/lspsaga/
	{
		"nvimdev/lspsaga.nvim",
		lazy = false,
		event = "LspAttach",
		config = function()
			require("lspsaga").setup({})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter", -- optional
			"nvim-tree/nvim-web-devicons", -- optional
		},
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		commit = "29be0919b91fb59eca9e90690d76014233392bef",
		opts = {},
		config = function()
			require("config.ibl")
		end,
	},

	{ "wakatime/vim-wakatime", lazy = false },
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		config = function()
			require("config.zen-mode")
		end,
	},

	{
		"mg979/vim-visual-multi",
		lazy = false,
	},
}
