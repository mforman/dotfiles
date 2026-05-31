local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
  },
  setup = function()
    require('nvim-treesitter').setup {}

    require('nvim-treesitter').install {
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
      'yaml',
    }

    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
