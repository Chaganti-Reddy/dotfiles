-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "chadwal",
  transparency = true,
  hl_add = {
    NvimTreeOpenedFolderName = { fg = "green", bold = true },
  },

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
  integrations = {},
  -- changed_themes = {},
  -- theme_toggle = { "onedark", "one_light" },
}

M.nvdash = { load_on_startup = true }
M.ui = {
  tabufline = {
    enabled = true,
    lazyload = false,
    order = { "treeOffset", "buffers", "tabs", "btns" },
    modules = nil,
  },
  cmp = {
    icons = true,
    lspkind_text = true,
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
  },
  telescope = { style = "borderless" }, -- borderless
  statusline = {
    theme = "vscode", -- default/vscode/vscode_colored/minimal
    -- default/round/block/arrow separators work only for default statusline theme
    -- round and block will work for minimal theme only
    separator_style = "default",
    order = nil,
    modules = nil,
  },
  term = {
    winopts = { number = false, relativenumber = false },
    sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
    float = {
      relative = "editor",
      row = 0.3,
      col = 0.25,
      width = 0.5,
      height = 0.4,
      border = "single",
    },
  },
  lsp = { signature = true },

  cheatsheet = {
    theme = "grid", -- simple/grid
    -- excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" }, -- can add group name or with mode
  },

  mason = { cmd = true, pkgs = {} },
}

return M
