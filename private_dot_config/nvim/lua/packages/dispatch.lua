local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'tpope/vim-dispatch' },
  },
  setup = function()
    vim.keymap.set('n', '<leader>xx', '<cmd>Make<cr>', { desc = 'E[x]ecute: make' })
    vim.keymap.set('n', '<leader>xd', ':Dispatch ', { desc = 'E[x]ecute: [D]ispatch...' })
    vim.keymap.set('n', '<leader>xs', ':Start ', { desc = 'E[x]ecute: [S]tart...' })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
