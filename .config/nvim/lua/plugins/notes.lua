return {
  "renerocksai/telekasten.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim"
  },
  cmd = "Telekasten",
  opts = {
    home = require "core.utils".get_config_key("notes", "file"),
    tag_notation = "yaml-bare",
  },
  config = function()
    require "which-key".add({
      { "<leader>z", "<cmd>Telekasten panel<CR>", desc = "Telekasten commands show" }
    })
  end
}
