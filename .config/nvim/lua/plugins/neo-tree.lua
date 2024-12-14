return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  event = "User DirOpened",
  cmd = "Neotree",
  keys = {
    -- { "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle [E]xplorer", opts = { silent = true } } },
    { "<leader>e",
      function()
        --local curr_ft = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(0), "ft")
        local curr_ft = vim.api.nvim_get_option_value('ft', { buf = vim.api.nvim_win_get_buf(0) })
        if string.find(curr_ft, "neo%-tree") then
          require("neo-tree.command").execute({ toggle = true })
        else
          require("neo-tree.command").execute({ focus = true })
        end
      end,
      { desc = "Toggle [E]xplorer", opts = { silent = true } }
    },
    { "<leader>b", "<cmd>Neotree buffers reveal float<CR>", { desc = "Show open buffers", opts = { silent = true } } },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  config = true,
}
