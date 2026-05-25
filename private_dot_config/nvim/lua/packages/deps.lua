local gh = require('core.util').gh

return {
  priority = 90,
  plugins = {
    { src = gh 'nvim-lua/plenary.nvim' },
    { src = gh 'nvim-tree/nvim-web-devicons' },
  },
}

-- vim: ts=2 sts=2 sw=2 et
