-- LSP Configuration & Plugins
-- Search for lspconfig to find the configuration.
local servers = {
  roslyn_ls = {},
  ruff = {},
  cssls = {},
  html = {},
  ts_ls = {},
  angularls = {},
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
  -- Defer loading dependencies until actually needed
  local function lsp(desc)
    return "LSP: " .. desc
  end

  local ok_telescope, tbi = pcall(require, "telescope.builtin")
  local ok_wk, wk = pcall(require, "which-key")


  if ok_wk then
    wk.add({
      { "<leader>rn", vim.lsp.buf.rename,      desc = lsp('[R]e[n]ame') },
      { "<leader>ca", vim.lsp.buf.code_action, desc = lsp('[C]ode [A]ction') },
      { "<leader>cf", vim.lsp.buf.format(),    desc = lsp('[C]ode [F]ormat') },
      {
        "<leader>D",
        ok_telescope and tbi.lsp_type_definitions or vim.lsp.buf.type_definition,
        desc = lsp('Type [D]efinition')
      },
      {
        "<leader>ds",
        ok_telescope and tbi.lsp_document_symbols or vim.lsp.buf.document_symbol,
        desc = lsp('[D]ocument [S]ymbols')
      },
      {
        "<leader>ws",
        ok_telescope and tbi.lsp_dynamic_workspace_symbols or vim.lsp.buf.workspace_symbol,
        desc = lsp('[W]orkspace [S]ymbols')
      },
      { "<leader>wa", vim.lsp.buf.add_workspace_folder,    desc = lsp('[W]orkspace [A]dd Folder') },
      { "<leader>wr", vim.lsp.buf.remove_workspace_folder, desc = lsp('[W]orkspace [R]emove Folder') },
      {
        "<leader>wl",
        function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end,
        desc = lsp('[W]orkspace [L]ist Folders')
      },
      { "<leader>gd", ok_telescope and tbi.lsp_definitions or vim.lsp.buf.definition,         desc = lsp('[G]oto [D]efinition') },
      { "<leader>gD", vim.lsp.buf.declaration,                                                desc = lsp('[G]oto [D]eclaration') },
      { "<leader>gr", ok_telescope and tbi.lsp_references or vim.lsp.buf.references,          desc = lsp('[G]oto [R]eferences') },
      { "<leader>gI", ok_telescope and tbi.lsp_implementations or vim.lsp.buf.implementation, desc = lsp('[G]oto [I]mplementation') },
      { "<leader>K",  vim.lsp.buf.hover,                                                      desc = lsp('Hover Documentation') },
      { "<leader>k>", vim.lsp.buf.signature_help,                                             desc = lsp('Signature Documentation') },
    })
  end

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

  -- Autocommands to highlight references of the word under the cursor when it rests there
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

local diagnostic_icons = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN]  = "",
  [vim.diagnostic.severity.INFO]  = "",
  [vim.diagnostic.severity.HINT]  = "",
}

---comment
---@param diagnostic vim.Diagnostic
---@param i integer
---@param total integer
---@return string
local function diagnostic_icon(diagnostic, i, total)
  local icon = (diagnostic_icons[diagnostic.severity] or "●")
  if total > 1 then
    return icon .. "(" .. i .. "/" .. total .. ") "
  end
  return icon
end

return {
  {
    "seblyng/roslyn.nvim",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      --empty for default settings
    }
  },
  {
    "neovim/nvim-lspconfig",
    event = { "VeryLazy" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "Mason" },
    dependencies = {
      "seblyng/roslyn.nvim", -- Automatically install LSPs to stdpath for neovim
      {
        "mason-org/mason.nvim",
        opts = {
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗"
            }
          },
          registries = {
            'github:mason-org/mason-registry',
            'github:crashdummyy/mason-registry',
          },
        },
      },
      {
        "mason-org/mason-lspconfig.nvim",
        opts = {
          ensure_installed = vim.tbl_keys(servers),
          automatic_enable = false,
        }
      },
      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})` or `config = true`
      { "j-hui/fidget.nvim",    opts = {} },
      { "hrsh7th/cmp-nvim-lsp", opts = {} },
    },
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = false,
      },
    },
    config = function(_, opts)
      vim.diagnostic.config({
        underline = true,
        update_in_insert = true,
        signs = {
          text = diagnostic_icons,
        },
        virtual_text = {
          spacing = 2,
          source = "if_many",
          -- prefix = "●",
          prefix = diagnostic_icon
        },
        severity_sort = true,
      })

      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      for server_name, server in pairs(servers) do
        -- Merge our overrides (capabilities, on_attach, custom settings)
        local config = vim.tbl_deep_extend("force", {
          name = server_name,
          capabilities = capabilities,
          on_attach = on_attach,
        }, server)

        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end

      -- Trigger FileType event for all existing buffers to attach LSP clients
      if vim.v.vim_did_enter == 1 then
        vim.cmd("doautoall nvim.lsp.enable FileType")
      end
    end,
  },
}
