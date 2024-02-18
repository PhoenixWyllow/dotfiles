-- There are `:help X` comments which you should run to read the help section for more information.

-- [[ Setting options ]]
require('core.config')

-- [[ Basic Keymaps ]]
require('core.keymaps')

-- [[ Autocommands ]]
require "core.autocmd"

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup('plugins', {})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
