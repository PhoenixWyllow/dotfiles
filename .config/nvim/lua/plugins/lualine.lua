-- See `:help lualine.txt`
return {
  -- Set lualine as statusline
  'nvim-lualine/lualine.nvim',
  opts = {
    options = {
      component_separators = '|',
      section_separators = '',
      -- globalstatus = true,
      ignore_focus = {
        "neo-tree"
      },
    },
    sections = {
      lualine_b = { { 'FugitiveHead', icon = '' }, },
    },
  },
}
