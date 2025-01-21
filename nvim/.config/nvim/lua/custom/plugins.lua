local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  { "ellisonleao/glow.nvim", config = true, cmd = "Glow" },

  {
    "stevearc/conform.nvim",
    --  for users those who want auto-save conform + lazyloading!
    -- event = "BufWritePre"
    config = function()
      require "custom.configs.conform"
    end,
  },

  {
    "kawre/leetcode.nvim",
    lazy = false,
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",

      -- optional
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>lq", mode = { "n" }, "<cmd>Leet tabs<cr>" },
      { "<leader>lm", mode = { "n" }, "<cmd>Leet menu<cr>" },
      { "<leader>lc", mode = { "n" }, "<cmd>Leet console<cr>" },
      { "<leader>li", mode = { "n" }, "<cmd>Leet info<cr>" },
      { "<leader>ll", mode = { "n" }, "<cmd>Leet lang<cr>" },
      { "<leader>ld", mode = { "n" }, "<cmd>Leet desc<cr>" },
      { "<leader>lr", mode = { "n" }, "<cmd>Leet run<cr>" },
      { "<leader>ls", mode = { "n" }, "<cmd>Leet submit<cr>" },
      { "<leader>ly", mode = { "n" }, "<cmd>Leet yank<cr>" },
      { "<leader>lp", mode = { "n" }, "<cmd>Leet list<cr>" },
    },
    config = function()
      require "custom.configs.leetcode"
    end,
  },
  {
    "vhyrro/luarocks.nvim",
    priority = 1001,
    opts= {
      rocks = { "magick" },
    },
  },
  {
    "3rd/image.nvim",
    lazy = false,
    build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
    dependencies = {"luarocks.nvim"},
    opts = {},
  },

  {
    "xeluxee/competitest.nvim",
    lazy = false,
    dependencies = "MunifTanjim/nui.nvim",
    config = function()
      require "custom.configs.competitest"
    end,
  },

{ -- This plugin
  "Zeioth/compiler.nvim",
  cmd = {"CompilerOpen", "CompilerToggleResults", "CompilerRedo"},
  dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
  opts = {},
},
{ -- The task runner we use
  "stevearc/overseer.nvim",
  commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
  cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
  opts = {
    task_list = {
      direction = "bottom",
      min_height = 25,
      max_height = 25,
      default_detail = 1
    },
  },
},

  {
    "jbyuki/nabla.nvim",
    lazy = false,
    -- config = function()
    --   require "custom.configs.nabla"
    -- end,
  },


  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   config = function()
  --     require("copilot").setup {
  --       panel = {
  --         enabled = true,
  --         auto_refresh = true,
  --         keymap = {
  --           jump_prev = "[[",
  --           jump_next = "]]",
  --           accept = "<CR>",
  --           refresh = "gr",
  --           open = "<M-CR>",
  --         },
  --         layout = {
  --           position = "bottom", -- | top | left | right
  --           ratio = 0.4,
  --         },
  --       },
  --       suggestion = {
  --         enabled = true,
  --         auto_trigger = true,
  --         debounce = 75,
  --         keymap = {
  --           accept = "<C-j>",
  --           accept_word = false,
  --           accept_line = false,
  --           -- next = "<M-]>",
  --           -- prev = "<M-[>",
  --           dismiss = "<C-]>",
  --         },
  --       },
  --       filetypes = {
  --         yaml = false,
  --         markdown = false,
  --         help = false,
  --         gitcommit = false,
  --         gitrebase = false,
  --         hgcommit = false,
  --         svn = false,
  --         cvs = false,
  --         ["."] = false,
  --       },
  --       copilot_node_command = "node", -- Node.js version must be > 18.x
  --       server_opts_overrides = {},
  --     }
  --   end,
  -- },
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      -- vim.g.codeium_disable_bindings = 1
      vim.g.codeium_enabled = true
      -- vim.g.codeium_filetypes_disabled_by_default = true
      vim.g.codeium_filetypes = {
        -- py = false,
      }
    end,

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
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      -- vim.g.vimtex_view_method = "okular"
      vim.g.vimtex_syntax_enabled = 1
    end,
  },

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
      require "custom.configs.ibl"
    end,
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("dashboard").setup {
        -- config
      }
      require "custom.configs.dashboard-nvim"
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
  },
  -- {
  --  "nvim-lualine/lualine.nvim",
  --    config = function()
  --      require "custom.configs.lualine"
  --    end,
  -- dependencies = { { "nvim-tree/nvim-web-devicons" } },
  --  },
  { "wakatime/vim-wakatime", lazy = false },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    config = function()
      require "custom.configs.zen-mode"
    end,
  },
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
  -- Custom Parameters (with defaults)
  {
    "David-Kunz/gen.nvim",
    lazy = false,
    opts = {
      model = "mistral", -- The default model to use.
      host = "localhost", -- The host running the Ollama service.
      port = "11434", -- The port on which the Ollama service is listening.
      display_mode = "float", -- The display mode. Can be "float" or "split".
      show_prompt = false, -- Shows the Prompt submitted to Ollama.
      show_model = false, -- Displays which model you are using at the beginning of your chat session.
      no_auto_close = false, -- Never closes the window automatically.
      init = function(options)
        pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
      end,
      -- Function to initialize Ollama
      command = function(options)
        return "curl --silent --no-buffer -X POST http://"
          .. options.host
          .. ":"
          .. options.port
          .. "/api/chat -d $body"
      end,
      -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
      -- This can also be a command string.
      -- The executed command must return a JSON object with { response, context }
      -- (context property is optional).
      -- list_models = '<omitted lua function>', -- Retrieves a list of model names
      debug = false, -- Prints errors and the command which is run.
    },
    -- require('gen').select_model()
  },
  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }
}

return plugins
