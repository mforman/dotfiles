local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'stevearc/conform.nvim' },
  },
  setup = function()
    require('conform').setup {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 2500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters = {
        stylua = {
          prepend_args = { '--indent-type', 'Spaces', '--indent-width', '2' },
        },
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        jsonc = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
        terraform = { 'terraform_fmt' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        python = { 'ruff_format' },
        sql = { 'sqlfluff' },
      },
    }

    vim.keymap.set('', '<leader>f', function()
      require('conform').format { async = true, lsp_format = 'fallback' }
    end, { desc = '[F]ormat buffer' })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
