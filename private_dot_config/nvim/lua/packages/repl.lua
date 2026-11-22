local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'Olical/conjure' },
  },
  setup = function()
    -- leave K and gd to the LSP
    vim.g['conjure#mapping#doc_word'] = false
    vim.g['conjure#mapping#def_word'] = false
    vim.g['conjure#filetypes'] = { 'clojure', 'python' }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
