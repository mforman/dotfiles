local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'tpope/vim-sleuth' },
    { src = gh 'tpope/vim-obsession' },
    { src = gh 'folke/todo-comments.nvim' },
    { src = gh 'echasnovski/mini.nvim' },
    { src = gh 'windwp/nvim-autopairs' },
  },
  setup = function()
    require('todo-comments').setup { signs = false }
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup()
    require('nvim-autopairs').setup {}
  end,
}

-- vim: ts=2 sts=2 sw=2 et
