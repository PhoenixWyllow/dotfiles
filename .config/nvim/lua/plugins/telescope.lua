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

      require("which-key").register({
        ["<leader>"] = {
          ["/"] = { function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            tls_b.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
              winblend = 10,
              previewer = false,
            })
          end, 'Fuzzily search in current buffer'
          },
          ["_"] = { tls_b.oldfiles, 'Find recently opened files' },
          ["?"] = { tls_b.help_tags, 'Find help tags' },
          ["<space>"] = { tls_b.buffers, "Find existing buffers" },
          k = { function()
            require("core.command_pallet").show({})
          end, "Open Command Pallet"
          },
          g = {
            name = "Git",
            f = { tls_b.git_files, "Git search files" },
            g = { "<cmd>LiveGrepGitRoot<cr>", "Git grep search on root" }
          },
          s = {
            name = "Search",
            ["/"] = { telescope_live_grep_open_files, "Search in open files" },
            s = { tls_b.builtin, "Search select telescope" },
            f = { tls_b.find_files, "Search files" },
            h = { tls_b.help_tags, "Search help" },
            w = { tls_b.grep_string, "Search current word" },
            g = { tls_b.live_grep, "Search by grep" },
            d = { tls_b.diagnostics, "Search diagnostics" },
            r = { tls_b.resume, "Search resume" },
          }
        }
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
