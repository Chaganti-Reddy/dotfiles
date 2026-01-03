return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      -- This runs the code you already wrote in lua/config/dashboard-nvim.lua
      require('config.dashboard-nvim')
    end,
    dependencies = { {'nvim-tree/nvim-web-devicons'}}
  }