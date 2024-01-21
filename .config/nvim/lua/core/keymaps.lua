local kmap = function(mode, keys, func, opts)
  vim.keymap.set(mode, keys, func, opts)
end

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
kmap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
kmap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
kmap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
kmap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
kmap('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
kmap('n', '<leader>Q', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
kmap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
