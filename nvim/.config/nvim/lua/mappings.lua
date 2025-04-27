require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map({ "n", "i" }, "<C-a>", "<ESC>ggVG", { desc = "Select all text" })

-- multiple modes
map({ "i", "n" }, "<C-k>", "<Up>", { desc = "Move up" })
map({ "i", "n" }, "<C-j>", "<Down>", { desc = "Move down" })
map({ "i", "n" }, "<C-h>", "<Left>", { desc = "Move left" })
map({ "i", "n" }, "<C-l>", "<Right>", { desc = "Move right" })

-- mapping with a lua function
-- map("n", "<A-i>", function()
--    -- do something
-- end, { desc = "Terminal toggle floating" })

-- Nvimtree
map({ "i", "n" }, "<C-n>", "<cmd> NvimTreeToggle <CR>", { desc = "Toggle Nvimtree" })

-- Vimtex
map({ "n" }, "<leader>cc", ":VimtexCompile<CR>", { desc = "Compile vimtex" })
map({ "n" }, "<leader>cx", ":VimtexClean<CR>", { desc = "Clean vimtex" })
map({ "n" }, "<leader>co", ":VimtexView<CR>", { desc = "View vimtex" })
map({ "n" }, "<leader>csv", ":VimtexStop<CR>", { desc = "Stop vimtex" })

-- Zen Mode
map("n", "<leader>z", ":ZenMode<CR>", { desc = "Toggle Zen Mode" })

-- Ollama
map("n", "<leader>gg", ":Gen<CR>", { desc = "Open Ollama" })

-- Compiler Nvim
map("n", "<leader>co", ":CompilerOpen<CR>", { desc = "Open Compiler" })
map("n", "<leader>csc", ":CompilerStop<CR>", { desc = "Stop Compiler" })
map("n", "<leader>ct", ":CompilerToggleResults<CR>", { desc = "Toggle Compiler Results" })


-- CompetiTest
map("n", "<leader>pr", ":CompetiTest run<CR>", { desc = "Competitest Run" })
map("n", "<leader>pa", ":CompetiTest receive testcases<CR>", { desc = "Competitest Receive Testcases" })
map("n", "<leader>pc", ":CompetiTest receive contest<CR>", { desc = "Competitest Receive Contest" })
map("n", "<leader>pp", ":CompetiTest receive problem<CR>", { desc = "Competitest Receive Problem" })
map("n", "<leader>pu", ":CompetiTest show_ui<CR>", { desc = "Competitest Show UI" })
map("n", "<leader>pd", ":CompetiTest delete_testcase<CR>", { desc = "Competitest Delete Testcase" })
map("n", "<leader>pA", ":CompetiTest add_testcase<CR>", { desc = "Competitest Add Testcase" })
map("n", "<leader>pe", ":CompetiTest edit_testcase<CR>", { desc = "Competitest Edit Testcase" })

-- delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', opts)

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

vim.keymap.set('n', '<C-Tab>', ':bnext<CR>', opts)
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', opts)
vim.keymap.set('n', '<leader>x', ':bdelete!<CR>', opts) -- close buffer
vim.keymap.set('n', '<leader>b', '<cmd> enew <CR>', opts) -- new buffer

-- Navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', opts)
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', opts)
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', opts)
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Keep last yanked when pasting
vim.keymap.set('v', 'p', '"_dP', opts)
