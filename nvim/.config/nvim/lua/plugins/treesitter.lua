return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				-- enable syntax highlighting
				highlight = {
					enable = true,
				},
				-- enable indentation
				indent = { enable = true },
				-- enable autotagging (w/ nvim-ts-autotag plugin)
				autotag = { enable = true },
				-- ensure these language parsers are installed
				ensure_installed = {
					"json",
					"javascript",
					"java",
					"javadoc",
					"query",
					"python",
					"typescript",
					"tsx",
					"php",
					"yaml",
					"html",
					"css",
					"markdown",
					"markdown_inline",
					"bash",
					"lua",
					"vim",
					"vimdoc",
					"c",
					"cpp",
					"dockerfile",
					"gitignore",
					"astro",
					"hyprlang",
				},
				-- auto install above language parsers
				auto_install = true,
			})
		end,
	},
}
