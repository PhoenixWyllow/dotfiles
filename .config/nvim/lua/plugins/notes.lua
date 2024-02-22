return {
  'renerocksai/telekasten.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim'
  },
  opts = {
    home = require "core.utils".get_config_key("notes", "file"),
    tag_notation = "yaml-bare",
  },
  config = function()
    require("which-key").register({
      ["<leader>z"] = { "<cmd>Telekasten panel<CR>", "Telekasten commands show" }
    })
  end
}
