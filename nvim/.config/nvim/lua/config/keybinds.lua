-- KEYBINDS
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>cd", vim.cmd.Ex, { desc = "Open netrw (Ex)" })

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Join lines with cursor stay
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor" })

-- Scroll and center
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- Paste without replacing clipboard
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Insert mode escape
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })

-- Quickfix list navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Quickfix next" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Quickfix previous" })

-- Disable Ex mode
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })

-- Location list navigation
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Location next" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Location previous" })

-- Doge doc generator
vim.keymap.set("n", "<leader>dg", "<cmd>DogeGenerate<cr>", { desc = "Generate docs (Doge)" })

-- Format PHP file
vim.keymap.set("n", "<leader>cc", "<cmd>!php-cs-fixer fix % --using-cache=no<cr>", { desc = "Format PHP file" })

-- Replace under-cursor word on line
vim.keymap.set("n", "<leader>s", [[:s/\<<C-r><C-w>\>//gI<Left><Left><Left>]], { desc = "Substitute word under cursor" })

-- Make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Yank to clipboard (SSH-friendly)
vim.keymap.set('n', '<leader>y', '<Plug>OSCYankOperator', { desc = "Yank to clipboard (op)" })
vim.keymap.set('v', '<leader>y', '<Plug>OSCYankVisual', { desc = "Yank to clipboard (visual)" })

-- Reload config
vim.keymap.set("n", "<leader>rl", "<cmd>source ~/.config/nvim/init.lua<cr>", { desc = "Reload config" })

-- Toggle Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

-- Move lines in normal mode
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", opts)
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", opts)

-- Move lines in visual mode
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", opts)

-- Save file
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- Select all text
vim.keymap.set({ "n", "i" }, "<C-a>", "<ESC>ggVG", { desc = "Select all text" })

-- Close buffer
vim.keymap.set('n', '<C-q>', ':bdelete<CR>', { desc = "Close buffer" })
vim.keymap.set('n', '<leader>to', '<cmd>enew<CR>', { desc = "New buffer" })

-- Navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', { desc = "Focus split up" })
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', { desc = "Focus split down" })
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', { desc = "Focus split left" })
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', { desc = "Focus split right" })

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', { desc = "Indent left (stay selected)" })
vim.keymap.set('v', '>', '>gv', { desc = "Indent right (stay selected)" })

-- Keep last yank when pasting
vim.keymap.set('v', 'p', '"_dP', { desc = "Paste without overwrite yank" })

-- Window navigation with Ctrl + h/j/k/l
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Switch window left" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Switch window right" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Switch window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Switch window up" })

-- Window navigation with Ctrl+x + arrows
vim.keymap.set("n", "<C-x><Left>",  "<C-w>h", { desc = "Switch window left (Ctrl-x)" })
vim.keymap.set("n", "<C-x><Right>", "<C-w>l", { desc = "Switch window right (Ctrl-x)" })
vim.keymap.set("n", "<C-x><Down>",  "<C-w>j", { desc = "Switch window down (Ctrl-x)" })
vim.keymap.set("n", "<C-x><Up>",    "<C-w>k", { desc = "Switch window up (Ctrl-x)" })

-- Split windows
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })
vim.keymap.set("n", "<leader>se", ":wincmd =<CR>", { desc = "Equalize split sizes" })

-- New file
vim.keymap.set("n", "<leader>nf", ":e %:h/", { desc = "New file in current directory" })

-- VimTeX keybindings
vim.keymap.set("n", "<leader>cc", "<cmd>VimtexCompile<CR>", { desc = "VimTeX: Compile" })
vim.keymap.set("n", "<leader>cx", "<cmd>VimtexClean<CR>", { desc = "VimTeX: Clean build files" })
vim.keymap.set("n", "<leader>co", "<cmd>VimtexView<CR>", { desc = "VimTeX: View PDF" })
vim.keymap.set("n", "<leader>csv", "<cmd>VimtexStop<CR>", { desc = "VimTeX: Stop compilation" })

vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Toggle Zen Mode" })

vim.keymap.set("n", "<leader>fm", function()
require("conform").format { lsp_fallback = true }
end, { desc = "General format file" })

-- Source current file
vim.keymap.set("n", "<leader><leader>", function()
vim.cmd("so")
end, { desc = "Source current file" })
