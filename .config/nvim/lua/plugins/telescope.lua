-- See `:help telescope` and `:help telescope.setup()`

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching in current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

local function kmap(k,f,o)
  vim.keymap.set('n',k,f,o)
end

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function ()
      vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

      -- See `:help telescope.builtin`
      local tls_b = require 'telescope.builtin'
      local function telescope_live_grep_open_files()
        tls_b.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end

      kmap('<leader>?', tls_b.oldfiles, { desc = '[?] Find recently opened files' })
      kmap('<leader><space>', tls_b.buffers, { desc = '[ ] Find existing buffers' })
      kmap('<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        tls_b.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })
      kmap('<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
      kmap('<leader>ss', tls_b.builtin, { desc = '[S]earch [S]elect Telescope' })
      kmap('<leader>gf', tls_b.git_files, { desc = 'Search [G]it [F]iles' })
      kmap('<leader>sf', tls_b.find_files, { desc = '[S]earch [F]iles' })
      kmap('<leader>sh', tls_b.help_tags, { desc = '[S]earch [H]elp' })
      kmap('<leader>sw', tls_b.grep_string, { desc = '[S]earch current [W]ord' })
      kmap('<leader>sg', tls_b.live_grep, { desc = '[S]earch by [G]rep' })
      kmap('<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
      kmap('<leader>sd', tls_b.diagnostics, { desc = '[S]earch [D]iagnostics' })
      kmap('<leader>sr', tls_b.resume, { desc = '[S]earch [R]esume' })

    end,
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function ()
      require('telescope').setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
          }
        }
      }
      require('telescope').load_extension('ui-select')
    end
  },
  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  -- {
  --   'nvim-telescope/telescope-fzf-native.nvim',
  --   -- NOTE: If you are having trouble with this installation,
  --   --       refer to the README for telescope-fzf-native for more instructions.
  --   build = 'cmake --workflow --preset x86_64-windows-gnu',
  --   enabled = vim.fn.executable("cmake") == 1,
  --   config = function()
  --     require("telescope").load_extension("fzf")
  --   end,
  -- },
}
