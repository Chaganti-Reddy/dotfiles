-- current buffer’s directory
local function get_buf_dir()
	local buf = vim.api.nvim_buf_get_name(0)
	if buf == "" then
		return vim.loop.cwd()
	end
	return vim.fn.fnamemodify(buf, ":p:h")
end

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	keys = {
		{
			"<A-f>",
			function()
				require("toggleterm").toggle(1, 0, get_buf_dir(), "float")
			end,
			mode = { "n", "t" },
			desc = "Float Term (buffer dir)",
		},
		{
			"<A-h>",
			function()
				require("toggleterm").toggle(2, 15, get_buf_dir(), "horizontal")
			end,
			mode = { "n", "t" },
			desc = "Vertical Term (buffer dir)",
		},
	},
	opts = {
		shade_terminals = true,
		start_in_insert = true,
		persist_size = true,
		close_on_exit = true,
		direction = "float", -- default, overridden per toggle
		float_opts = {
			border = "curved",
			width = function()
				local cols = vim.o.columns
				local lines = vim.o.lines
				local size = math.floor(math.min(cols, lines) * 0.8)
				return size
			end,
			height = function()
				local cols = vim.o.columns
				local lines = vim.o.lines
				local size = math.floor(math.min(cols, lines) * 0.8)
				return size
			end,
		},
	},
}
