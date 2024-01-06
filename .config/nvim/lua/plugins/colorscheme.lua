return {
  -- { "scottmckendry/cyberdream.nvim",
  --   priority = 1000,
  --   config = function()
  --       require("cyberdream").setup({
  --           -- Recommended - see "Configuring" below for more config options
  --           transparent = true,
  --           italic_comments = true,
  --           hide_fillchars = true,
  --           borderless_telescope = true,
  --       })
  --       vim.cmd.colorscheme 'cyberdream' -- set the colorscheme
  --   end,
  -- },
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    opts = {
      style = 'darker',
      transparent = true,
    },
    config = function()
      require('onedark').load()
    end,
  },
}
