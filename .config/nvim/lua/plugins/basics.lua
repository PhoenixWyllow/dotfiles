return {
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
      wk.register {
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
        ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
      }

      wk.register({
        ["<leader>M"] = { "<cmd>messages<cr>", "Show Messages" },
        -- Diagnostic keymaps
        ["[d"] = { vim.diagnostic.goto_prev, 'Go to previous diagnostic message' },
        ["]d"] = { vim.diagnostic.goto_next, 'Go to next diagnostic message' },
        ["<leader>Q"] = { vim.diagnostic.open_float, 'Open floating diagnostic message' },
        ["<leader>q"] = { vim.diagnostic.setloclist, 'Open diagnostics list' },
      })
      -- register which-key VISUAL mode
      -- required for visual <leader>hs (hunk stage) to work
      wk.register({
        ["<leader>"] = { name = 'VISUAL <leader>' },
        ["<leader>h"] = { 'Git [H]unk' },
      }, { mode = 'v' })
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
}
