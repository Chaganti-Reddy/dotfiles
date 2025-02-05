return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  "nvim-lua/plenary.nvim",

  {
    "nvchad/ui",
    config = function()
      require "nvchad"
    end,
  },

  {
    "nvchad/base46",
    lazy = true,
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  "nvzone/volt",

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
      },
    },
  },



  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "stevearc/conform.nvim",
    --  for users those who want auto-save conform + lazyloading!
    -- event = "BufWritePre"
    config = function()
      require "configs.conform"
    end,
  },

  -- Codeium in Neovim
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    -- config = function()
    --   -- vim.g.codeium_disable_bindings = 1
    --   vim.g.codeium_enabled = true
    --   vim.g.codeium_filetypes_disabled_by_default = true
    --   vim.g.codeium_filetypes = {
    --   }
    -- end,

    -- config = function ()
    --     -- Change '<C-g>' here to any keycode you like.
    --     vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
    --     vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
    --     vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
    --     vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
    --   end

    -- Clear current suggestion 	codeium#Clear() 	<C-]>
    -- Next suggestion 	codeium#CycleCompletions(1) 	<M-]>
    -- Previous suggestion 	codeium#CycleCompletions(-1) 	<M-[>
    -- Insert suggestion 	codeium#Accept() 	<Tab>
    -- Manually trigger suggestion 	codeium#Complete() 	<M-Bslash>
    -- Accept word from suggestion 	codeium#AcceptNextWord() 	<C-k>
    -- Accept line from suggestion 	codeium#AcceptNextLine() 	<C-l>
  },

  -- Latex Compilation in Neovim
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      -- vim.g.vimtex_view_method = "okular"
      vim.g.vimtex_syntax_enabled = 1
    end,
  },

  -- https://nvimdev.github.io/lspsaga/
  {
    'nvimdev/lspsaga.nvim',
    lazy = false,
    event = "LspAttach",
    config = function()
      require('lspsaga').setup({})
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    }
  },


  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    commit = "29be0919b91fb59eca9e90690d76014233392bef",
    opts = {},
    config = function()
      require "configs.ibl"
    end,
  },

  -- MultiCursors for Neovim
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      "smoka7/hydra.nvim",
    },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>m",
        "<cmd>MCstart<cr>",
        desc = "Create a selection for selected text or word under the cursor",
      },
    },
  },
}
