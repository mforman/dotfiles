-------------------------------------------------------------------------------
-- Options
-------------------------------------------------------------------------------
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir= os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

-------------------------------------------------------------------------------
-- Keymap
-------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-------------------------------------------------------------------------------
-- Bootstrap Package Manager
-------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-------------------------------------------------------------------------------
-- Plugins
-------------------------------------------------------------------------------
require("lazy").setup {
  { "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      config = function()
	-- load the colorscheme here
	vim.cmd([[colorscheme tokyonight]])
      end,
  },
  { "nvim-lualine/lualine.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
        opts = { theme = "tokyonight" } },
  { "folke/which-key.nvim",
      event = "VeryLazy",
      init = function()
          vim.o.timeout = true
          vim.o.timeoutlen = 300
      end,
      opts = { }
  },
  { "folke/neoconf.nvim", 
      cmd = "Neoconf" },
  { "folke/neodev.nvim" },
  { "nvim-telescope/telescope.nvim", 
      tag = "0.1.4", 
      dependencies = "nvim-lua/plenary.nvim",
      keys = {
          { "<leader>ff", "<CMD>Telescope find_files<CR>", mode = { "n" } },
	  { "<leader>fg", "<CMD>Telescope git_files<CR>", mode = { "n" } },
	  { "<leader>fs", "<CMD>Telescope live_grep<CR>", mode = { "n" } },
      }
   },
   { "nvim-treesitter/nvim-treesitter",
       build = ":TSUpdate",
       config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = { "c", "lua", "python" },
                auto_install = true,
		highlight = { enable = true, }
            }
        end },
    { "ThePrimeagen/vim-be-good" }
}

