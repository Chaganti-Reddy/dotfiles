---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },

    --  format with conform
    ["<leader>fm"] = {
      function()
        require("conform").format()
      end,
      "formatting",
    },
    -- compile vimtex
    ["<leader>cc"] = { ":VimtexCompile<CR>", "compile vimtex" },
    -- view using vintex
    ["<leader>cv"] = { ":VimtexView<CR>", "view vimtex" },
    -- Enter Zen Mode using z 
    ["<leader>z"] = { ":ZenMode<CR>", "zen mode" },
    ["<leader>gg"] = { ":Gen<CR>", "Open Ollama" },

    -- Compiler.nvim 
    ["<leader>co"] = { "<cmd>CompilerOpen<cr>", "Compiler open" },
    ["<leader>cs"] = { "<cmd>CompilerStop<cr>", "Compiler Stop" },
    ["<leader>ct"] = { "<cmd>CompilerToggleResults<cr>", "Compiler Toggle Results" },

    -- CompetiTest
    ["<leader>pr"] = { "<cmd>CompetiTest run<cr>", "Competitest run" },
    ["<leader>pa"] = { "<cmd>CompetiTest receive testcases<cr>", "Competitest Receive Testcases" },
    ["<leader>pc"] = { "<cmd>CompetiTest receive contest<cr>", "Competitest Receive Contest" },
    ["<leader>pp"] = { "<cmd>CompetiTest receive problem<cr>", "Competitest Receive Problem" },
    ["<leader>pu"] = { "<cmd>CompetiTest show_ui<cr>", "Competitest Show UI" },
    ["<leader>pd"] = { "<cmd>CompetiTest delete_testcase<cr>", "Competitest Delete Testcase" },
    ["<leader>pA"] = { "<cmd>CompetiTest add_testcase<cr>", "Competitest Add Testcase" },
    ["<leader>pe"] = { "<cmd>CompetiTest edit_testcase<cr>", "Competitest Edit Testcase" },
  },
  v = {
    [">"] = { ">gv", "indent" },
    ["<"] = { "<gv", "indent" },
    ["<leader>gg"] = { ":Gen<CR>", "Open Ollama" },
  },
}

-- more keybinds!

return M
