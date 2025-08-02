return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		-- your configuration comes here
		-- follow this link - https://github.com/folke/which-key.nvim to know how to configure
		-- which-key based on your own and default plugins keybindings
		-- or leave it empty to use the default settings
	},
}
