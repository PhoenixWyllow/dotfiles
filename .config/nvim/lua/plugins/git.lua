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
        require("which-key").register({
          ["<leader>"] = {
            -- Actions
            gS = { gs.stage_buffer, git("Stage buffer") },
            gR = { gs.reset_buffer, git("Reset buffer") },
            gb = { function() gs.blame_line { full = false } end, git("blame line") },
            gd = { gs.diffthis, git("diff against index") },
            gD = { function() gs.diffthis '~' end, git("diff against last commit") },
            --Toggles
            tb = { gs.toggle_current_line_blame, git("toggle blame line") },
            td = { gs.toggle_deleted, git("toggle show deleted") },
          }
        }, { buffer = bufnr })
      end,
    },
  },
}
