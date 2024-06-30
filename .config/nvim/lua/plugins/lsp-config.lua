-- LSP Configuration & Plugins
-- Search for lspconfig to find the configuration.
local servers = {
  marksman = {},
  taplo = {},
  lua_ls = {
    -- cmd = {...},
    -- filetypes { ...},
    -- capabilities = {},
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        format = {
          enable = true,
          -- Put format options here
          -- NOTE: the value should be STRING!!
          defaultConfig = {
            indent_style = "space",
            indent_size = "2",
          }
        },
        -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
}

local on_attach = function(client, bufnr)
  local function lsp(desc)
    return "LSP: " .. desc
  end
  require("which-key").register({
    ["<leader>"] = {
      rn = { vim.lsp.buf.rename, lsp('[R]e[n]ame') },
      ca = { vim.lsp.buf.code_action, lsp('[C]ode [A]ction') },
      D = { require("telescope.builtin").lsp_type_definitions, lsp('Type [D]efinition') },
      ds = { require("telescope.builtin").lsp_document_symbols, lsp('[D]ocument [S]ymbols') },
      ws = { require("telescope.builtin").lsp_dynamic_workspace_symbols, lsp('[W]orkspace [S]ymbols') },
      wa = { vim.lsp.buf.add_workspace_folder, lsp('[W]orkspace [A]dd Folder') },
      wr = { vim.lsp.buf.remove_workspace_folder, lsp('[W]orkspace [R]emove Folder') },
      wl = { function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, lsp('[W]orkspace [L]ist Folders') },
    },
    g = {
      d = { require("telescope.builtin").lsp_definitions, lsp('[G]oto [D]efinition') },
      D = { vim.lsp.buf.declaration, lsp('[G]oto [D]eclaration') },
      r = { require("telescope.builtin").lsp_references, lsp('[G]oto [R]eferences') },
      I = { require("telescope.builtin").lsp_implementations, lsp('[G]oto [I]mplementation') },
    },
    -- See `:help K` for why this keymap
    K = { vim.lsp.buf.hover, lsp('Hover Documentation') },
    ["<C-k>"] = { vim.lsp.buf.signature_help, lsp('Signature Documentation') },
  })

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

  -- Autocommands to highlight references of the word under the cursor when it rests there
  --    See `:help CursorHold` for information about when this is executed
  -- The highlights will be cleared when the cursor is moved.
  if client and client.server_capabilities.documentHighlightProvider then
    local lsp_h_g = vim.api.nvim_create_augroup("lsp_highlight", { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      group = lsp_h_g,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = bufnr,
      group = lsp_h_g,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "Mason" },
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      {
        "williamboman/mason.nvim",
        opts = {
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗"
            }
          }
        },
      },
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          auto_install = true,
        }
      },
      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})` or `config = true`
      { "j-hui/fidget.nvim",    opts = {} },
      { "hrsh7th/cmp-nvim-lsp", opts = {} },
    },
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 2,
          source = "if_many",
          -- prefix = "●",
          -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
          -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
          prefix = "icons",
        },
        severity_sort = true,
      },
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = false,

      },
    },
    config = function()
      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Ensure the servers above are installed
      local mason_lspconfig = require "mason-lspconfig"

      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      mason_lspconfig.setup_handlers {
        function(server_name)
          local server = servers[server_name] or {}
          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            filetypes = server.filetypes,
            settings = server.settings
          }
        end,
      }
    end
  },
}
