return {
  -- automatically adjusts 'shiftwidth' and 'expandtab' heuristically based on
  -- the current file, files of the same type in current and parent directories, modelines, or EditorConfig
  'tpope/vim-sleuth',
  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {},
    cmd = "WhichKey",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    keys = {
      { '<C-w>', '<cmd>WhichKey<CR>', { desc = "[W]hichkey show all keys" } }
    },
    config = function()
      local wk = require('which-key')
      -- document existing key chains

      wk.add({
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>w', group = '[W]orkspace', },
      })

      wk.add({
        { "<leader>M", "<cmd>messages<cr>",       desc = "Show Messages" },
        -- Diagnostic keymaps
        { "[d",        vim.diagnostic.goto_prev,  desc = 'Go to previous diagnostic message' },
        { "]d",        vim.diagnostic.goto_next,  desc = 'Go to next diagnostic message' },
        { "<leader>Q", vim.diagnostic.open_float, desc = 'Open floating diagnostic message' },
        { "<leader>q", vim.diagnostic.setloclist, desc = 'Open diagnostics list' },
      })

      -- register which-key VISUAL mode
      -- required for visual <leader>hs (hunk stage) to work
      wk.add({
        mode = 'v',
        { "<leader>",  group = 'VISUAL <leader>' },
        { "<leader>h", desc = 'Git [H]unk' },
      })
    end
  },

  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      exclude = {
        filetypes = {
          "help",
          "dashboard",
          "neo-tree",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
  },

  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    event = "VeryLazy",
    opts = {}
  },
  {
    'sudormrfbin/cheatsheet.nvim',
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
      { 'nvim-lua/popup.nvim' },
      { 'nvim-lua/plenary.nvim' },
    },
    cmd = "Cheatsheet",
    keys = {
      { '<leader>.', '<cmd>Cheatsheet!<CR>', { desc = "Show Cheatsheet" } }
    },

  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {}
  },
}
