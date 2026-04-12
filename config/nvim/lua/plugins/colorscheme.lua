return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      integrations = {
        cmp = true,
        dashboard = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        mason = true,
        markdown = true,
        neotree = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      }
    },
    config = function()
      vim.cmd.colorscheme "catppuccin"
    end
  },
}
