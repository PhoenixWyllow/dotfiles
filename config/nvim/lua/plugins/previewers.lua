return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    -- build = function()
    --   vim.fn["mkdp#util#install"]()
    -- end,
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    keys = {
      {
        "<leader>mp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    ft = "markdown", -- If you decide to lazy-load anyway
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    opts = {
      -- code_blocks = {
      --   style = "language",
      --
      --   language_direction = "right",
      --   min_width = 60,
      --   pad_char = " ",
      --   pad_amount = 3,
      --
      --   language_names = {
      --     ["txt"] = "Text"
      --   },
      --
      --   hl = "MarkviewCode",
      --   info_hl = "MarkviewCodeInfo",
      --
      --   sign = true,
      --   sign_hl = nil
      -- }
    },
    config = function(_, opts)
      local presets = require("markview.presets");
      opts.checkboxes = presets.checkboxes.nerd
      -- opts.headings = presets.headings.slanted

      require("markview").setup(opts)
    end
  },
}
