return {
  -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  event = { "BufEnter" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  build = ':TSUpdate',
  config = function()
    require("nvim-treesitter.install").compilers = { "zig", vim.fn.getenv('CC'), "cc", "gcc", "clang", "cl" } -- in windows, yaml seems to fail on load if installed without zig or clang
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.powershell = {
      install_info = {
        url = "https://github.com/airbus-cert/tree-sitter-powershell",
        files = { "src/parser.c", "src/scanner.c" }
      },
      filetype = "ps1",
      used_by = { "psm1", "psd1", "pssc", "psxml", "cdxml" }
    }
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      ensure_installed = { "bash", "lua", "toml", "markdown", "markdown_inline", "json", "json5", "jsonc", "yaml" },
      ignore_install = {},
      -- Autoinstall languages that are not installed. Defaults to false
      auto_install = true,
      sync_install = false,

      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<M-space>',
        },
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },

        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },

        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
      },
    })
  end
}
