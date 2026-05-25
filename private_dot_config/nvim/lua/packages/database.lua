local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'tpope/vim-dadbod' },
    { src = gh 'kristijanhusak/vim-dadbod-ui' },
    { src = gh 'kristijanhusak/vim-dadbod-completion' },
  },
  setup = function()
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}

-- vim: ts=2 sts=2 sw=2 et
