local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'coder/claudecode.nvim' },
  },
  setup = function()
    require('claudecode').setup()
    vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCode<CR>', { desc = '[A]I: Toggle [C]laude Code' })
    vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<CR>', { desc = '[A]I: [S]end selection to Claude' })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
