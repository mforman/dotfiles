-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Stop losing the cursor
vim.o.guicursor = ""

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Tab Settings
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.smartindent = true

-- Hide the mode since it's in lualine
vim.o.showmode = false

-- Turn off relative line numbers in INSERT mode
local group = vim.api.nvim_create_augroup("numbertoggle", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave" }, {
  pattern = "*",
  callback = function()
    vim.wo.relativenumber = true
  end,
  group = group
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter" }, {
  pattern = "*",
  callback = function()
    vim.wo.relativenumber = false
  end,
  group = group
})

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Leave some space
vim.o.scrolloff = 8

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.api.nvim_set_hl(0, 'Comment', { italic = true })

-- vim: ts=2 sts=2 sw=2 et
