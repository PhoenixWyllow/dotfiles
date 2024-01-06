-- See `:help lualine.txt`
return {
  -- Set lualine as statusline
  'nvim-lualine/lualine.nvim',
  opts = {
    options = {
      icons_enabled = false,
      theme = 'onedark',
      -- theme = 'cyberdream',
      component_separators = '|',
      section_separators = '',
    },
  },
}
