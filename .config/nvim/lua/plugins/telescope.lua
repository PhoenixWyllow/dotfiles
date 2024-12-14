-- See `:help telescope` and `:help telescope.setup()`

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = require("core.utils").find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` and `fzf` are available.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- NOTE: Refer to the README for telescope-fzf-native for more info.
        build = "make",
      }
    },
    opts = {
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown { winblend = 10 }
        }
      },
    },
    config = function()
      require("telescope").load_extension("ui-select")
      if vim.fn.executable("make") == 1 and vim.fn.executable("fzf") == 1 then
        require("telescope").load_extension("fzf")
      end

      -- Telescope live_grep in git root
      vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

      -- See `:help telescope.builtin`
      local tls_b = require "telescope.builtin"
      local function telescope_live_grep_open_files()
        tls_b.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end

      require "which-key".add({
        {
          "<leader>/",
          function()
            tls_b.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
              winblend = 10,
              previewer = false,
            })
          end,
          desc = 'Fuzzily search in current buffer'
        },
        { '<leader>_',       tls_b.oldfiles,  desc = 'Find recently opened files' },
        { '<leader>?',       tls_b.help_tags, desc = 'Find help tags' },
        { "<leader><space>", tls_b.buffers,   desc = "Find existing buffers" },
        {
          '<leader>k',
          function()
            require("core.command_pallet").show({})
          end,
          desc = "Open Command Pallet"
        },
        { '<leader>g',  group = "Git" },
        { '<leader>gf', tls_b.git_files,                desc = "Git search files" },
        { '<leader>gg', "<cmd>LiveGrepGitRoot<cr>",     desc = "Git grep search on root" },
        { '<leader>s',  group = 'Search' },
        { '<leader>s/', telescope_live_grep_open_files, desc = "Search in open files" },
        { '<leader>ss', tls_b.builtin,                  desc = "Search select telescope" },
        { '<leader>sf', tls_b.find_files,               desc = "Search files" },
        { '<leader>sh', tls_b.help_tags,                desc = "Search help" },
        { '<leader>sw', tls_b.grep_string,              desc = "Search current word" },
        { '<leader>sg', tls_b.live_grep,                desc = "Search by grep" },
        { '<leader>sd', tls_b.diagnostics,              desc = "Search diagnostics" },
      })
    end,
  },
  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` and `fzf` are available.
  --[[   {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: Refer to the README for telescope-fzf-native for more info.
    build = 'make',
    enabled = vim.fn.executable("make") == 1 and vim.fn.executable("fzf") == 1,
    config = function()
      require("telescope").load_extension("fzf")
    end,
  }, ]]
}
