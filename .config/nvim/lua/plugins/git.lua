-- See `:help gitsigns.txt`
return {
  -- Git related plugins
  "tpope/vim-fugitive", --git

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "" },
        change = { text = "" },
        delete = { text = "" },
        changedelete = { text = "" },
        untracked = { text = "" }
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function git(desc)
          return "git " .. desc
        end
        require "which-key".add({
          buffer = bufnr,
          -- Actions
          { "<leader>gS", gs.stage_buffer,                               desc = git("Stage buffer") },
          { "<leader>gR", gs.reset_buffer,                               desc = git("Reset buffer") },
          { "<leader>gb", function() gs.blame_line { full = false } end, desc = git("blame line") },
          { "<leader>gd", gs.diffthis,                                   desc = git("diff against index") },
          { "<leader>gD", function() gs.diffthis '~' end,                desc = git("diff against last commit") },
          --Toggles
          { "<leader>tb", gs.toggle_current_line_blame,                  desc = git("toggle blame line") },
          { "<leader>td", gs.toggle_deleted,                             desc = git("toggle show deleted") },
        })
      end,
    },
  },
}
