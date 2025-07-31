-- OPTIONS
local set = vim.opt
local opt = vim.opt
local o = vim.o
local g = vim.g

--line nums
o.number = true
o.relativenumber = true
o.numberwidth = 2
o.ruler = false
o.laststatus = 3
o.showmode = false

-- indentation and tabs
set.tabstop = 4
set.shiftwidth = 4
set.autoindent = true
set.expandtab = true

-- search settings
opt.fillchars = { eob = " " }
o.ignorecase = true
o.smartcase = true
o.mouse = "a"

-- appearance
set.termguicolors = true
set.background = "dark"
set.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400

-- disable nvim intro
opt.shortmess:append("sI")

-- cursor line
-- set.cursorline = true

-- 80th column
-- set.colorcolumn = "80"

-- clipboard
set.clipboard:append("unnamedplus")
o.cursorline = true
o.cursorlineopt = "number"

-- backspace
set.backspace = "indent,eol,start"

-- split windows
set.splitbelow = true
set.splitright = true

-- dw/diw/ciw works on full-word
set.iskeyword:append("-")

-- keep cursor at least 8 rows from top/bot
set.scrolloff = 8

-- undo dir settings
set.swapfile = false
set.backup = false
set.undodir = os.getenv("HOME") .. "/.vim/undodir"
set.undofile = true

-- incremental search
set.incsearch = true

-- faster cursor hold
set.updatetime = 50

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append("<>[]hl")

-- disable some default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- add binaries installed by mason.nvim to path
local is_windows = vim.fn.has("win32") ~= 0
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) .. delim .. vim.env.PATH
