-- =============================================================================
--  1. GENERAL SETTINGS & BASICS
-- =============================================================================
vim.g.mapleader = " "

-- Save file (Ctrl+S)
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- Select all text (Ctrl+A)
vim.keymap.set({ "n", "i" }, "<C-a>", "<ESC>ggVG", { desc = "Select all text" })

-- Delete single character without copying into register
vim.keymap.set("n", "x", '"_x')

-- Vertical Scroll and center
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Search result centering
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- =============================================================================
--  2. EDITING & MOVING TEXT
-- =============================================================================
-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- Join lines but keep cursor in place
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor" })

-- Paste without replacing clipboard
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent Right" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Indent Left" })

-- Toggle Comment (Ctrl + /) - FIX: Wrapped in a function for lazy-loading
vim.keymap.set({ "n", "v" }, "<C-_>", function()
    require('Comment.api').toggle.linewise.current()
end, { desc = "Toggle Comment" })

-- =============================================================================
--  3. VS CODE STYLE TOOLS (Explorer, Search, Terminal)
-- =============================================================================
-- File Explorer (NeoTree)
vim.keymap.set("n", "<C-b>", "<cmd>Neotree toggle<CR>", { desc = "Toggle File Explorer" })

-- File Search (Telescope) - FIX: Wrapped in functions to prevent startup error
vim.keymap.set("n", "<C-p>", function() require('telescope.builtin').find_files() end, { desc = "Find Files" })
vim.keymap.set("n", "<C-S-f>", function() require('telescope.builtin').live_grep() end, { desc = "Global Search (Grep)" })
vim.keymap.set("n", "<leader>sw", function() require('telescope.builtin').grep_string() end, { desc = "Search Word under cursor" })
vim.keymap.set("n", "<leader><space>", function() require('telescope.builtin').buffers() end, { desc = "Find Open Buffers" })

-- Terminal (ToggleTerm)
vim.keymap.set({"n", "t"}, "<C-\\>", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle Terminal" })

-- Buffer/Tab Navigation
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close Current Buffer" })

-- =============================================================================
--  4. WINDOW MANAGEMENT (Splits & Navigation)
-- =============================================================================
-- Create Splits
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split Vertically" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split Horizontally" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close Split" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize Split Sizes" })

-- Navigate Splits
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move Left" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move Right" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move Down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move Up" })
vim.keymap.set("n", "<C-S-Left>", "<C-w>h", { desc = "Move Left" })
vim.keymap.set("n", "<C-S-Right>", "<C-w>l", { desc = "Move Right" })
vim.keymap.set("n", "<C-S-Down>", "<C-w>j", { desc = "Move Down" })
vim.keymap.set("n", "<C-S-Up>", "<C-w>k", { desc = "Move Up" })

-- Resize Splits
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase width" })

-- =============================================================================
--  5. HARPOON (Super Fast Navigation)
-- =============================================================================
-- FIX: Wrapped in functions to prevent startup error
vim.keymap.set("n", "<leader>a", function() require("harpoon"):list():add() end, { desc = "Harpoon: Add File" })
vim.keymap.set("n", "<C-e>", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, { desc = "Harpoon: Menu" })

vim.keymap.set("n", "<C-1>", function() require("harpoon"):list():select(1) end, { desc = "Harpoon File 1" })
vim.keymap.set("n", "<C-2>", function() require("harpoon"):list():select(2) end, { desc = "Harpoon File 2" })
vim.keymap.set("n", "<C-3>", function() require("harpoon"):list():select(3) end, { desc = "Harpoon File 3" })
vim.keymap.set("n", "<C-4>", function() require("harpoon"):list():select(4) end, { desc = "Harpoon File 4" })

-- =============================================================================
--  6. LSP & CODING (Intellisense)
-- =============================================================================
-- Format Code
vim.keymap.set("n", "<leader>fm", function() require("conform").format({ lsp_fallback = true }) end, { desc = "Format File" })

-- Go to Definition / References
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gr", function() require('telescope.builtin').lsp_references() end, { desc = "Find References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })

-- Rename & Actions
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })

-- Diagnostics (Errors)
vim.keymap.set("n", "<leader>d[", vim.diagnostic.goto_prev, { desc = "Previous Error" })
vim.keymap.set("n", "<leader>d]", vim.diagnostic.goto_next, { desc = "Next Error" })

-- =============================================================================
--  7. MISC PLUGINS
-- =============================================================================
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
vim.keymap.set("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
vim.keymap.set("n", "<leader>ex", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
vim.keymap.set("n", "<leader>cc", "<cmd>VimtexCompile<CR>", { desc = "VimTeX: Compile" })
vim.keymap.set("n", "<leader>cv", "<cmd>VimtexView<CR>", { desc = "VimTeX: View" })
vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader><leader>", function() vim.cmd("so") end, { desc = "Reload Config" })
