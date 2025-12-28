-- =============================================================================
--  1. SYSTEM, BASICS & VS CODE DEFAULTS
-- =============================================================================
vim.g.mapleader = " "

-- Helper to map keys across multiple modes (Normal, Insert, Visual)
-- This ensures Ctrl+S or Ctrl+B works even if you are typing
local function map(modes, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(modes, lhs, rhs, opts)
end

-- SAVE FILE (Ctrl+S) - Works everywhere
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- SELECT ALL (Ctrl+A)
map({ "n", "i", "v" }, "<C-a>", "<Esc>ggVG", { desc = "Select all text" })

-- UNDO (Ctrl+Z) - VS Code Style
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("n", "<C-z>", "u", { desc = "Undo" })

-- ESCAPE INSERT MODE (Ctrl+C)
map("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })

-- COPY/PASTE (System Clipboard)
-- Your old config used OSCYank. Standard Neovim "+y is usually better now.
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map("x", "<leader>p", [["_dP]], { desc = "Paste without replacing clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- =============================================================================
--  2. SMART TOGGLING (Ctrl+B, Ctrl+`, etc.)
-- =============================================================================

-- SMART EXPLORER (Ctrl+B)
-- Logic: If FileTree is focused -> Close it. Otherwise -> Focus it.
map({ "n", "i", "v" }, "<C-b>", function()
    -- Check if we are currently IN the Neo-tree window
    if vim.bo.filetype == "neo-tree" then
        vim.cmd("Neotree close")
    else
        vim.cmd("Neotree focus")
    end
end, { desc = "Toggle Explorer" })

-- TERMINAL (Ctrl+` or Ctrl+\)
map({ "n", "i", "v", "t" }, "<C-\\>", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle Terminal" })
map({ "n", "i", "v", "t" }, "<C-`>", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle Terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- COMMENTS (Ctrl+/)
-- Note: Ctrl+/ often sends Ctrl+_ in terminals
map({ "n", "i", "v" }, "<C-_>", function() require('Comment.api').toggle.linewise.current() end, { desc = "Toggle Comment" })
map({ "n", "i", "v" }, "<C-/>", function() require('Comment.api').toggle.linewise.current() end, { desc = "Toggle Comment" })

-- =============================================================================
--  3. SEARCH (Ctrl+P, Ctrl+F) - CRASH PROOF
-- =============================================================================
-- This wrapper prevents "module not found" errors if Telescope loads late
local function safe_telescope(command)
    local status, builtin = pcall(require, "telescope.builtin")
    if not status then
        vim.notify("Telescope not loaded yet", vim.log.levels.WARN)
        return
    end
    builtin[command]()
end

map({ "n", "i", "v" }, "<C-p>", function() safe_telescope("find_files") end, { desc = "Find Files" })
map({ "n", "i", "v" }, "<C-S-f>", function() safe_telescope("live_grep") end, { desc = "Global Search" })
map("n", "<leader><space>", function() safe_telescope("buffers") end, { desc = "Find Buffers" })

-- =============================================================================
--  4. NAVIGATION (Tabs, Splits, Windows)
-- =============================================================================

-- TABS (Bufferline)
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Tab" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Tab" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close Tab" })
map("n", "<C-q>", "<cmd>bdelete<CR>", { desc = "Close Tab (Alt)" }) -- From your old config

-- SPLITS
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical Split" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal Split" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close Split" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize Splits" })

-- WINDOW NAVIGATION (Ctrl + h/j/k/l)
map({ "n", "i" }, "<C-h>", "<C-w>h", { desc = "Focus Left" })
map({ "n", "i" }, "<C-l>", "<C-w>l", { desc = "Focus Right" })
map({ "n", "i" }, "<C-j>", "<C-w>j", { desc = "Focus Down" })
map({ "n", "i" }, "<C-k>", "<C-w>k", { desc = "Focus Up" })

-- WINDOW RESIZING (Ctrl + Arrows)
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Height +" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Height -" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Width -" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Width +" })

-- =============================================================================
--  5. EDITING (Moving lines, Indent)
-- =============================================================================
-- Move lines (Alt + j/k)
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Indenting (Tab/Shift+Tab in Visual)
map("v", "<Tab>", ">gv", { desc = "Indent Right" })
map("v", "<S-Tab>", "<gv", { desc = "Indent Left" })
map("v", "<", "<gv", { desc = "Indent Left" })
map("v", ">", ">gv", { desc = "Indent Right" })

-- Join lines (J)
map("n", "J", "mzJ`z", { desc = "Join lines keep cursor" })

-- Scroll and Center
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down Center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up Center" })
map("n", "n", "nzzzv", { desc = "Next Match Center" })
map("n", "N", "Nzzzv", { desc = "Prev Match Center" })

-- =============================================================================
--  6. YOUR CUSTOM TOOLS (Restored from old config)
-- =============================================================================

-- Doge (Docs)
map("n", "<leader>dg", "<cmd>DogeGenerate<CR>", { desc = "Generate Docs" })

-- PHP Formatter
map("n", "<leader>cc", "<cmd>!php-cs-fixer fix % --using-cache=no<CR>", { desc = "Format PHP" })

-- Make Executable
map("n", "<leader>ex", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make Executable" })

-- Search & Replace Word under cursor
map("n", "<leader>s", [[:s/\<<C-r><C-w>\>//gI<Left><Left><Left>]], { desc = "Replace word" })

-- VimTeX
map("n", "<leader>tc", "<cmd>VimtexCompile<CR>", { desc = "Compile Latex" })
map("n", "<leader>tv", "<cmd>VimtexView<CR>", { desc = "View Latex" })
map("n", "<leader>tx", "<cmd>VimtexStop<CR>", { desc = "Stop Latex" })

-- Zen Mode
map("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Zen Mode" })

-- Undotree
map("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undo Tree" })

-- =============================================================================
--  7. HARPOON & LSP (Wrapped for Safety)
-- =============================================================================
map("n", "<leader>a", function() require("harpoon"):list():add() end, { desc = "Harpoon Add" })
map("n", "<C-e>", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, { desc = "Harpoon Menu" })
map("n", "<C-1>", function() require("harpoon"):list():select(1) end, { desc = "Harpoon 1" })
map("n", "<C-2>", function() require("harpoon"):list():select(2) end, { desc = "Harpoon 2" })

-- Format File
map("n", "<leader>fm", function()
    local status, conform = pcall(require, "conform")
    if status then conform.format({ lsp_fallback = true }) else vim.lsp.buf.format() end
end, { desc = "Format File" })

-- LSP
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gr", function() safe_telescope("lsp_references") end, { desc = "Find References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover Info" })
map("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Reload Config
map("n", "<leader><leader>", function() vim.cmd("so") end, { desc = "Reload Config" })
