-- utils: current buffer dir (reuse your get_buf_dir if it's already global)
local function get_buf_dir()
	local buf = vim.api.nvim_buf_get_name(0)
	if buf == "" then
		return vim.loop.cwd()
	end
	return vim.fn.fnamemodify(buf, ":p:h")
end

-- tiny helpers
local function exists(path)
	return vim.loop.fs_stat(path) ~= nil
end
local function read_json(path)
	local ok, decoded = pcall(function()
		local f = io.open(path, "r")
		if not f then
			return nil
		end
		local s = f:read("*a")
		f:close()
		return vim.json.decode(s)
	end)
	return ok and decoded or nil
end

-- Project-aware command resolvers
local function npm_script(script)
	local pkg = get_buf_dir() .. "/package.json"
	if exists(pkg) then
		local j = read_json(pkg)
		if j and j.scripts and j.scripts[script] then
			return "npm run " .. script
		end
	end
	return nil
end

local function cmake_build_cmd()
	if exists(get_buf_dir() .. "/CMakeLists.txt") then
		-- out-of-source build dir "build"
		return "cmake -S . -B build && cmake --build build"
	end
	return nil
end

local function make_cmd(target)
	if exists(get_buf_dir() .. "/Makefile") or exists(get_buf_dir() .. "/makefile") then
		return target and ("make " .. target) or "make"
	end
	return nil
end

local function cargo_cmd(sub)
	if exists(get_buf_dir() .. "/Cargo.toml") then
		return "cargo " .. (sub or "run")
	end
	return nil
end

-- Map filetypes to default run/build
local runners = {
	python = {
		run = function()
			return "python3 " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
		end,
	},
	javascript = {
		run = function()
			return npm_script("start") or ("node " .. vim.fn.fnameescape(vim.fn.expand("%:p")))
		end,
		build = function()
			return npm_script("build")
		end,
	},
	typescript = {
		run = function()
			return npm_script("start")
				or (
					exists(get_buf_dir() .. "/tsconfig.json")
						and "ts-node " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
					or "tsx " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
				)
		end,
		build = function()
			return npm_script("build") or "tsc -p ."
		end,
	},
	lua = {
		run = function()
			return "lua " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
		end,
	},
	sh = {
		run = function()
			return "bash " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
		end,
	},
	zsh = {
		run = function()
			return "zsh " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
		end,
	},
	c = {
		-- build to ./<filebase> and run
		run = function()
			local out = vim.fn.expand("%:r")
			local file = vim.fn.fnameescape(vim.fn.expand("%:p"))
			return make_cmd()
				or cmake_build_cmd()
				or (
					"cc "
					.. file
					.. " -O2 -Wall -o "
					.. vim.fn.fnameescape(out)
					.. " && "
					.. "./"
					.. vim.fn.fnameescape(out)
				)
		end,
		build = function()
			local out = vim.fn.expand("%:r")
			local file = vim.fn.fnameescape(vim.fn.expand("%:p"))
			return make_cmd() or cmake_build_cmd() or ("cc " .. file .. " -O2 -Wall -o " .. vim.fn.fnameescape(out))
		end,
	},
	cpp = {
		run = function()
			local out = vim.fn.expand("%:r")
			local file = vim.fn.fnameescape(vim.fn.expand("%:p"))
			return make_cmd()
				or cmake_build_cmd()
				or (
					"c++ "
					.. file
					.. " -std=c++20 -O2 -Wall -o "
					.. vim.fn.fnameescape(out)
					.. " && "
					.. "./"
					.. vim.fn.fnameescape(out)
				)
		end,
		build = function()
			local out = vim.fn.expand("%:r")
			local file = vim.fn.fnameescape(vim.fn.expand("%:p"))
			return make_cmd()
				or cmake_build_cmd()
				or ("c++ " .. file .. " -std=c++20 -O2 -Wall -o " .. vim.fn.fnameescape(out))
		end,
	},
	rust = {
		run = function()
			return cargo_cmd("run")
		end,
		build = function()
			return cargo_cmd("build")
		end,
	},
	go = {
		run = function()
			return "go run " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
		end,
		build = function()
			return "go build ./..."
		end,
	},
	java = {
		run = function()
			local file = vim.fn.expand("%:p")
			local dir = get_buf_dir()
			local main = vim.fn.expand("%:t:r")
			return "javac " .. vim.fn.fnameescape(file) .. " && cd " .. vim.fn.fnameescape(dir) .. " && java " .. main
		end,
		build = function()
			local file = vim.fn.expand("%:p")
			return "javac " .. vim.fn.fnameescape(file)
		end,
	},
	markdown = {
		run = function()
			-- needs 'glow' installed
			return "glow -p " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
		end,
	},
	tex = {
		build = function()
			-- needs latexmk
			return "latexmk -pdf -interaction=nonstopmode -synctex=1 " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
		end,
	},
}

-- Global fallbacks if filetype isn't in the table
local function fallback_run()
	-- Prefer project tools if present
	return make_cmd() or cargo_cmd("run") or npm_script("start")
end
local function fallback_build()
	return make_cmd() or cargo_cmd("build") or npm_script("build") or cmake_build_cmd()
end

-- Open command in ToggleTerm
local function run_in_term(cmd, title)
	if not cmd or #cmd == 0 then
		vim.notify("No command available for this file/project", vim.log.levels.WARN)
		return
	end
	local ok, term = pcall(require, "toggleterm.terminal")
	if not ok then
		vim.notify("toggleterm not found", vim.log.levels.ERROR)
		return
	end
	local Terminal = term.Terminal
	Terminal:new({
		cmd = cmd,
		dir = get_buf_dir(),
		close_on_exit = false,
		direction = "float",
		on_open = function(t)
			-- set a nice title (requires a terminal that shows titles)
			pcall(vim.api.nvim_buf_set_name, t.bufnr, title or "Run")
		end,
	}):toggle()
end

-- Resolve the right command for current buffer
local function resolve_cmd(kind) -- "run" | "build"
	local ft = vim.bo.filetype
	local spec = runners[ft]
	if spec and spec[kind] then
		return spec[kind]()
	end
	if kind == "run" then
		return fallback_run()
	end
	return fallback_build()
end

-- Keymaps:
-- Alt-r -> smart run (project-aware or filetype)
-- Alt-b -> smart build (project-aware or filetype)
vim.keymap.set({ "n", "t" }, "<A-r>", function()
	vim.cmd("silent! w")
	run_in_term(resolve_cmd("run"), "Smart Run")
end, { desc = "Smart Run (project/filetype)" })

vim.keymap.set({ "n", "t" }, "<A-b>", function()
	vim.cmd("silent! w")
	run_in_term(resolve_cmd("build"), "Smart Build")
end, { desc = "Smart Build (project/filetype)" })

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
