local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'coder/claudecode.nvim' },
  },
  setup = function()
    require('claudecode').setup {
      terminal = { provider = 'none' },
    }
    vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<CR>', { desc = '[A]I: [S]end selection to Claude' })
    vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeAdd %<CR>', { desc = '[A]I: [A]dd current file to Claude' })
    vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCodeStatus<CR>', { desc = '[A]I: [C]laude connection status' })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
