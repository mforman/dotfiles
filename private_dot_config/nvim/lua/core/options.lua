vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

vim.opt.completeopt = 'menu,menuone,noselect,popup'

local psqlrc_nvim = vim.fn.expand '~/.psqlrc_nvim'
if vim.fn.filereadable(psqlrc_nvim) then
  vim.env.PSQLRC = psqlrc_nvim
end

local python_pyenv = vim.fn.expand '~/.pyenv/versions/neovim/bin/python3'
if vim.fn.filereadable(python_pyenv) then
  vim.g.python3_host_prog = python_pyenv
end

-- vim: ts=2 sts=2 sw=2 et
