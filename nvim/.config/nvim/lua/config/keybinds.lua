-- =============================================================================
--  1. SYSTEM & GENERAL
-- =============================================================================
vim.g.mapleader = " "

-- Helper to map multiple modes
local function map(modes, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(modes, lhs, rhs, opts)
end

-- SAVE & SELECT ALL (Works in Insert Mode too)
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map({ "n", "i", "v" }, "<C-a>", "<Esc>ggVG", { desc = "Select all" })

-- UNDO (Ctrl+Z) - VS Code style
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("n", "<C-z>", "u", { desc = "Undo" })

-- ESCAPE INSERT MODE (Ctrl+C) - Your original bind
map("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })

-- DISABLE EX MODE (Q)
map("n", "Q", "<nop>", { desc = "Disable Ex mode" })

-- =============================================================================
--  2. VS CODE STYLE TOGGLES (Smart Logic)
-- =============================================================================

-- SMART EXPLORER TOGGLE (Ctrl + B)
-- 1. If Closed -> Open & Focus
-- 2. If Open (but you are in code) -> Focus Tree
-- 3. If Focused (you are in tree) -> Close
map({ "n", "i", "v" }, "<C-b>", function()
    if vim.bo.filetype == "neo-tree" then
        vim.cmd("Neotree close")
    else
        vim.cmd("Neotree focus")
    end
end, { desc = "Toggle Explorer" })

-- TERMINAL TOGGLE (Ctrl + ` or Ctrl + \)
map({ "n", "i", "v", "t" }, "<C-\\>", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle Terminal" })
map({ "n", "i", "v", "t" }, "<C-`>", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle Terminal" })
-- Exit Terminal Mode with Esc
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- COMMENT (Ctrl + /)
map({ "n", "i", "v" }, "<C-_>", function() require('Comment.api').toggle.linewise.current() end, { desc = "Toggle Comment" })
map({ "n", "i", "v" }, "<C-/>", function() require('Comment.api').toggle.linewise.current() end, { desc = "Toggle Comment" })

-- =============================================================================
--  3. SEARCH (Safe Plugin Loading)
-- =============================================================================
local function run_telescope(builtin_name)
    local status, builtin = pcall(require, "telescope.builtin")
    if not status then return end
    builtin[builtin_name]()
end

-- FIND FILES (Ctrl + P)
map({ "n", "i", "v" }, "<C-p>", function() run_telescope("find_files") end, { desc = "Find Files" })

-- GLOBAL SEARCH (Ctrl + Shift + F)
map({ "n", "i", "v" }, "<C-S-f>", function() run_telescope("live_grep") end, { desc = "Global Search" })

-- FIND OPEN BUFFERS
map("n", "<leader><space>", function() run_telescope("buffers") end, { desc = "Find Buffers" })

-- =============================================================================
--  4. NAVIGATION & EDITING
-- =============================================================================
-- Move Lines (Alt + j/k)
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move up" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move down" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move up" })

-- Indenting (Tab / Shift+Tab)
map("v", "<Tab>", ">gv", { desc = "Indent Right" })
map("v", "<S-Tab>", "<gv", { desc = "Indent Left" })
map("v", "<", "<gv", { desc = "Indent Left" })
map("v", ">", ">gv", { desc = "Indent Right" })

-- Tab Navigation (Tab / Shift+Tab)
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close Buffer" })

-- Window Splits
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical Split" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal Split" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close Split" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize Splits" })

-- Window Navigation (Ctrl + H/J/K/L)
map({ "n", "i" }, "<C-h>", "<C-w>h", { desc = "Go Left" })
map({ "n", "i" }, "<C-l>", "<C-w>l", { desc = "Go Right" })
map({ "n", "i" }, "<C-j>", "<C-w>j", { desc = "Go Down" })
map({ "n", "i" }, "<C-k>", "<C-w>k", { desc = "Go Up" })

-- Window Navigation (Ctrl + Shift + Arrows)
map("n", "<C-S-Left>", "<C-w>h", { desc = "Go Left" })
map("n", "<C-S-Right>", "<C-w>l", { desc = "Go Right" })
map("n", "<C-S-Down>", "<C-w>j", { desc = "Go Down" })
map("n", "<C-S-Up>", "<C-w>k", { desc = "Go Up" })

-- Resize Splits (Ctrl + Arrows)
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Inc Height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Dec Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Dec Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Inc Width" })

-- Join lines (J)
map("n", "J", "mzJ`z", { desc = "Join lines" })

-- =============================================================================
--  5. HARPOON & LSP (Coding Tools)
-- =============================================================================
map("n", "<leader>a", function() require("harpoon"):list():add() end, { desc = "Harpoon Add" })
map("n", "<C-e>", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, { desc = "Harpoon Menu" })
map("n", "<C-1>", function() require("harpoon"):list():select(1) end, { desc = "File 1" })
map("n", "<C-2>", function() require("harpoon"):list():select(2) end, { desc = "File 2" })
map("n", "<C-3>", function() require("harpoon"):list():select(3) end, { desc = "File 3" })
map("n", "<C-4>", function() require("harpoon"):list():select(4) end, { desc = "File 4" })

-- Format Code
map("n", "<leader>fm", function()
    local status, conform = pcall(require, "conform")
    if status then conform.format({ lsp_fallback = true }) else vim.lsp.buf.format() end
end, { desc = "Format" })

-- LSP
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gr", function() run_telescope("lsp_references") end, { desc = "Find References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover Doc" })
map("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- =============================================================================
--  6. SPECIFIC PLUGINS & CUSTOM SCRIPTS (Restored)
-- =============================================================================
-- Doge (Doc Generator)
map("n", "<leader>dg", "<cmd>DogeGenerate<CR>", { desc = "Generate Docs (Doge)" })

-- PHP Formatter (Your custom script)
map("n", "<leader>cc", "<cmd>!php-cs-fixer fix % --using-cache=no<CR>", { desc = "Format PHP" })

-- Make Executable
map("n", "<leader>ex", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make Executable" })

-- Undotree
map("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

-- Search & Replace Word
map("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace Word" })

-- VimTeX (Latex)
map("n", "<leader>tx", "<cmd>VimtexCompile<CR>", { desc = "VimTeX Compile" })
map("n", "<leader>tv", "<cmd>VimtexView<CR>", { desc = "VimTeX View" })
map("n", "<leader>tc", "<cmd>VimtexClean<CR>", { desc = "VimTeX Clean" })
map("n", "<leader>ts", "<cmd>VimtexStop<CR>", { desc = "VimTeX Stop" })

-- Zen Mode
map("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Toggle Zen Mode" })

-- Reload Config
map("n", "<leader><leader>", function() vim.cmd("so") end, { desc = "Reload Config" })
