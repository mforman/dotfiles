local gh = require('core.util').gh

return {
  priority = 100,
  plugins = {
    { src = gh 'catppuccin/nvim' },
  },
  setup = function()
    require('catppuccin').setup {
      transparent_background = true,
    }
    vim.cmd.colorscheme 'catppuccin-macchiato'
  end,
}

-- vim: ts=2 sts=2 sw=2 et
