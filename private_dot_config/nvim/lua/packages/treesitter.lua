local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
  },
  setup = function()
    require('nvim-treesitter').setup {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },
      auto_install = true,
    }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
