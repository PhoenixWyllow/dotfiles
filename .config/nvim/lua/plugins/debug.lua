local config = {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui" },
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
          "williamboman/mason.nvim",
        },
        cmd = { "DapInstall", "DapUninstall" },
        opts = {},
      },
    },
    keys = {
      { "<F5>",    function() require("dap").continue() end,          desc = "Continue" },
      { "<F10>",   function() require("dap").step_over() end,         desc = "Step over" },
      { "<F11>",   function() require("dap").step_into() end,         desc = "Step into" },
      { "<S-F11>", function() require("dap").step_out() end,          desc = "Step out" },
      { "<S-F5>",  function() require("dap").terminate() end,         desc = "Terminate" },
      { "<F9>",    function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    },
    config = function()
      local dap = require "dap"
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end
  },
}

return config
