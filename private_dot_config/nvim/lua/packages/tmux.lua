local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'jpalardy/vim-slime' },
    { src = gh 'christoomey/vim-tmux-navigator' },
    { src = gh 'tpope/vim-dispatch' },
  },
  setup = function()
    vim.g.slime_target = 'tmux'
    vim.g.slime_default_config = { socket_name = 'default', target_pane = '{last}' }
    vim.g.slime_dont_ask_default = 1
    vim.g.slime_bracketed_paste = 1
    vim.g.slime_no_mappings = 1

    vim.keymap.set('x', '<leader>es', '<Plug>SlimeRegionSend', { desc = '[E]val: [S]end selection' })
    vim.keymap.set('n', '<leader>es', '<Plug>SlimeParagraphSend', { desc = '[E]val: [S]end paragraph' })
    vim.keymap.set('n', '<leader>el', '<Plug>SlimeLineSend', { desc = '[E]val: [L]ine' })
    vim.keymap.set('n', '<leader>ec', '<cmd>SlimeConfig<cr>', { desc = '[E]val: [C]onfigure target' })

    vim.g.tmux_navigator_no_mappings = 1

    vim.keymap.set('n', '<M-Left>', '<cmd>TmuxNavigateLeft<cr>', { desc = 'Navigate left (nvim/tmux)' })
    vim.keymap.set('n', '<M-Down>', '<cmd>TmuxNavigateDown<cr>', { desc = 'Navigate down (nvim/tmux)' })
    vim.keymap.set('n', '<M-Up>', '<cmd>TmuxNavigateUp<cr>', { desc = 'Navigate up (nvim/tmux)' })
    vim.keymap.set('n', '<M-Right>', '<cmd>TmuxNavigateRight<cr>', { desc = 'Navigate right (nvim/tmux)' })

    vim.keymap.set('n', '<leader>xx', '<cmd>Make<cr>', { desc = 'E[x]ecute: make' })
    vim.keymap.set('n', '<leader>xd', ':Dispatch ', { desc = 'E[x]ecute: [D]ispatch...' })
    vim.keymap.set('n', '<leader>xs', ':Start ', { desc = 'E[x]ecute: [S]tart...' })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
