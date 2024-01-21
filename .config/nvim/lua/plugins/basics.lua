return {
  -- Git related plugins
  'tpope/vim-fugitive', --git
  'tpope/vim-rhubarb',  --hub
  'tpope/vim-sleuth',

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {},
    cmd = "WhichKey",
    keys = {
      { '<leader>W>', '<cmd>WhichKey<CR>', { desc = "[W]hichkey show all keys" } }
    },
    config = function()
      -- document existing key chains
      require('which-key').register {
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
        ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
      }
      -- register which-key VISUAL mode
      -- required for visual <leader>hs (hunk stage) to work
      require('which-key').register({
        ['<leader>'] = { name = 'VISUAL <leader>' },
        ['<leader>h'] = { 'Git [H]unk' },
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
          "dashboard"
        },
      },
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },
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
