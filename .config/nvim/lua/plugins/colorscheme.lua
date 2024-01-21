return {
  --[[ {
    'Mofiqul/dracula.nvim',
    priority = 1000,
    config = function ()
      vim.cmd.colorscheme 'dracula'
    end
  }, ]]
  { "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      integrations = {
        dashboard = true,
        mason = true,
        neotree = true,
        whichkey = true,
      }
    },
    config = function ()
      vim.cmd.colorscheme "catppuccin"
    end
  },
  --[[ {
    'navarasu/onedark.nvim',
    priority = 1000,
    opts = {
      style = 'darker',
      transparent = true,
    },
    config = function()
      require('onedark').load()
    end,
  }, ]]
}
