-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

require('options')
require('keymaps')
require('plugins.lazy')
