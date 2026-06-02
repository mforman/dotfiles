local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'tpope/vim-dadbod' },
    { src = gh 'kristijanhusak/vim-dadbod-ui' },
    { src = gh 'kristijanhusak/vim-dadbod-completion' },
  },
  setup = function()
    vim.g.db_ui_use_nerd_fonts = 1

    local group = vim.api.nvim_create_augroup('dadbod_completion', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      pattern = { 'sql', 'mysql', 'plsql' },
      callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'vim_dadbod_completion#omni'
        vim.api.nvim_create_autocmd('TextChangedI', {
          buffer = ev.buf,
          callback = function()
            if vim.fn.pumvisible() == 1 then
              return
            end
            local col = vim.fn.col '.' - 1
            local before = vim.fn.getline('.'):sub(col, col)
            if before:match '[%w_.]' then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true), 'n', false)
            end
          end,
        })
      end,
    })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
