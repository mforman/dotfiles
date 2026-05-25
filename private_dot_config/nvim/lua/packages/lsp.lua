local gh = require('core.util').gh

local servers = {
  lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
      },
    },
  },
  marksman = {
    cmd = { 'marksman', 'server' },
    filetypes = { 'markdown' },
    root_markers = { '.marksman.toml', '.git' },
  },
  basedpyright = {
    cmd = { 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  },
  yamlls = {
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml', 'yaml.docker-compose' },
    root_markers = { '.git' },
    settings = {
      yaml = {
        schemaStore = { enable = true },
      },
    },
  },
  terraformls = {
    cmd = { 'terraform-ls', 'serve' },
    filetypes = { 'terraform', 'terraform-vars', 'tf' },
    root_markers = { '.terraform', '*.tf', '.git' },
  },
  helm_ls = {
    cmd = { 'helm_ls', 'serve' },
    filetypes = { 'helm' },
    root_markers = { 'Chart.yaml', 'values.yaml', '.git' },
  },
  dockerls = {
    cmd = { 'docker-langserver', '--stdio' },
    filetypes = { 'dockerfile' },
    root_markers = { 'Dockerfile', '.git' },
  },
  docker_compose_language_service = {
    cmd = { 'docker-compose-langserver', '--stdio' },
    filetypes = { 'yaml.docker-compose' },
    root_markers = { 'docker-compose.yaml', 'docker-compose.yml', 'compose.yaml', 'compose.yml', '.git' },
  },
  bashls = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'sh', 'bash', 'zsh' },
    root_markers = { '.git' },
  },
  powershell_es = {
    cmd = (function()
      local pkg = vim.fn.stdpath 'data' .. '/mason/packages/powershell-editor-services'
      local state = vim.fn.stdpath 'state'
      return {
        'pwsh',
        '-NoLogo',
        '-NoProfile',
        '-Command',
        pkg .. '/PowerShellEditorServices/Start-EditorServices.ps1',
        '-BundledModulesPath',
        pkg,
        '-SessionDetailsPath',
        state .. '/powershell_es.session.json',
        '-LogPath',
        state .. '/powershell_es.log',
        '-LogLevel',
        'Normal',
        '-Stdio',
      }
    end)(),
    filetypes = { 'ps1', 'psm1', 'psd1' },
    root_markers = { '.git' },
  },
  vtsls = {
    cmd = { 'vtsls', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  },
}

return {
  plugins = {
    { src = gh 'folke/lazydev.nvim' },
    { src = gh 'mason-org/mason.nvim' },
    { src = gh 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    { src = gh 'j-hui/fidget.nvim' },
  },
  setup = function()
    require('lazydev').setup {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    }

    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          return diagnostic.message
        end,
      },
    }

    require('mason').setup()
    require('mason-tool-installer').setup {
      ensure_installed = {
        'lua-language-server',
        'marksman',
        'basedpyright',
        'yaml-language-server',
        'terraform-ls',
        'helm-ls',
        'dockerfile-language-server',
        'docker-compose-language-service',
        'bash-language-server',
        'powershell-editor-services',
        'vtsls',
        'stylua',
        'prettierd',
        'shfmt',
        'ruff',
        'sqlfluff',
      },
    }

    require('fidget').setup()

    local enabled_servers = {}
    local lsp_augroup = vim.api.nvim_create_augroup('lsp-lazy-enable', { clear = true })

    for name, config in pairs(servers) do
      vim.lsp.config[name] = config
      if config.filetypes and #config.filetypes > 0 then
        vim.api.nvim_create_autocmd('FileType', {
          group = lsp_augroup,
          pattern = config.filetypes,
          callback = function()
            if not enabled_servers[name] then
              vim.lsp.enable(name)
              enabled_servers[name] = true
            end
          end,
        })
      end
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end

        if client and client:supports_method 'textDocument/completion' then
          vim.lsp.completion.enable(true, client.id, event.buf, {
            autotrigger = true,
          })
        end
      end,
    })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
