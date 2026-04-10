-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- Built-in completion options (replaces nvim-cmp)
vim.opt.completeopt = 'menu,menuone,noselect,popup'

-- [[ Environment Variables ]]

local psqlrc_nvim = vim.fn.expand '~/.psqlrc_nvim'
if vim.fn.filereadable(psqlrc_nvim) then
  vim.env.PSQLRC = psqlrc_nvim
end

local python_pyenv = vim.fn.expand '~/.pyenv/versions/neovim/bin/python3'
if vim.fn.filereadable(python_pyenv) then
  vim.g.python3_host_prog = python_pyenv
end

-- [[ Basic Keymaps ]]

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('x', '<leader>p', '"_dP')
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')

-- [[ Basic Autocommands ]]

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Filetype detection ]]

vim.filetype.add {
  pattern = {
    -- Detect Helm chart templates and values files
    ['.*/templates/.*%.yaml'] = 'helm',
    ['.*/templates/.*%.tpl'] = 'helm',
    ['helmfile.*%.yaml'] = 'helm',
    ['docker%-compose.*%.yaml'] = 'yaml.docker-compose',
    ['docker%-compose.*%.yml'] = 'yaml.docker-compose',
    ['compose.*%.yaml'] = 'yaml.docker-compose',
    ['compose.*%.yml'] = 'yaml.docker-compose',
  },
  filename = {
    ['Chart.yaml'] = 'helm',
  },
}

-- [[ Install plugins with vim.pack (replaces lazy.nvim) ]]

local gh = function(x)
  return 'https://github.com/' .. x
end

vim.pack.add {
  -- Core utilities
  { src = gh 'nvim-lua/plenary.nvim' },
  { src = gh 'nvim-tree/nvim-web-devicons' },

  -- Detect tabstop and shiftwidth automatically
  { src = gh 'tpope/vim-sleuth' },

  -- Git signs
  { src = gh 'lewis6991/gitsigns.nvim' },

  -- Which-key
  { src = gh 'folke/which-key.nvim' },

  -- Telescope
  { src = gh 'nvim-telescope/telescope.nvim' },
  { src = gh 'nvim-telescope/telescope-fzf-native.nvim' },
  { src = gh 'nvim-telescope/telescope-ui-select.nvim' },

  -- LSP support
  { src = gh 'folke/lazydev.nvim' },
  { src = gh 'williamboman/mason.nvim' },
  { src = gh 'williamboman/mason-lspconfig.nvim' },
  { src = gh 'WhoIsSethDaniel/mason-tool-installer.nvim' },
  { src = gh 'j-hui/fidget.nvim' },

  -- Formatting
  { src = gh 'stevearc/conform.nvim' },

  -- Colorscheme
  { src = gh 'catppuccin/nvim' },

  -- Todo comments
  { src = gh 'folke/todo-comments.nvim' },

  -- Mini (ai, surround)
  { src = gh 'echasnovski/mini.nvim' },

  -- Treesitter (use main branch for 0.12 compatibility)
  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },

  -- Autopairs
  { src = gh 'windwp/nvim-autopairs' },

  -- Statusline
  { src = gh 'nvim-lualine/lualine.nvim' },

  -- Obsidian
  { src = gh 'epwalsh/obsidian.nvim' },

  -- Render markdown
  { src = gh 'MeanderingProgrammer/render-markdown.nvim' },

  -- Database
  { src = gh 'tpope/vim-dadbod' },
  { src = gh 'kristijanhusak/vim-dadbod-ui' },
  { src = gh 'kristijanhusak/vim-dadbod-completion' },
}

-- NOTE: telescope-fzf-native requires a build step. After first install, run:
--   cd ~/.local/share/nvim-next/site/pack/core/opt/telescope-fzf-native.nvim && make

-- [[ Plugin Configuration ]]

-- Colorscheme (set up first)
require('catppuccin').setup {
  transparent_background = true,
}
vim.cmd.colorscheme 'catppuccin-macchiato'

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function()
      gitsigns.diffthis '@'
    end, { desc = 'git [D]iff against last commit' })
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
  end,
}

-- Which-key
require('which-key').setup {
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
    keys = vim.g.have_nerd_font and {} or {
      Up = '<Up> ',
      Down = '<Down> ',
      Left = '<Left> ',
      Right = '<Right> ',
      C = '<C-...> ',
      M = '<M-...> ',
      D = '<D-...> ',
      S = '<S-...> ',
      CR = '<CR> ',
      Esc = '<Esc> ',
      ScrollWheelDown = '<ScrollWheelDown> ',
      ScrollWheelUp = '<ScrollWheelUp> ',
      NL = '<NL> ',
      BS = '<BS> ',
      Space = '<Space> ',
      Tab = '<Tab> ',
      F1 = '<F1>',
      F2 = '<F2>',
      F3 = '<F3>',
      F4 = '<F4>',
      F5 = '<F5>',
      F6 = '<F6>',
      F7 = '<F7>',
      F8 = '<F8>',
      F9 = '<F9>',
      F10 = '<F10>',
      F11 = '<F11>',
      F12 = '<F12>',
    },
  },
  spec = {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  },
}

-- Telescope
require('telescope').setup {
  defaults = {
    mappings = {
      n = { ['<c-d>'] = require('telescope.actions').delete_buffer },
      i = { ['<c-d>'] = require('telescope.actions').delete_buffer },
    },
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })

vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

-- Lazydev (Lua LSP support for Neovim API)
require('lazydev').setup {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}

-- Diagnostic config
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

-- [[ LSP Configuration (native vim.lsp.config + lazy FileType enabling) ]]

-- All server configs in one place. Add new servers here.
-- Each server is lazily enabled when a matching filetype is opened.
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
  sqls = {
    cmd = { 'sqls' },
    filetypes = { 'sql', 'mysql', 'plsql' },
    root_markers = { '.git' },
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
    cmd = { 'pwsh', '-NoLogo', '-NoProfile', '-Command', 'EditorServices\\Start-EditorServices.ps1' },
    filetypes = { 'ps1', 'psm1', 'psd1' },
    root_markers = { '.git' },
  },
  vtsls = {
    cmd = { 'vtsls', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  },
}

-- Mason (installs LSP servers and tools)
require('mason').setup()
require('mason-tool-installer').setup {
  ensure_installed = vim.list_extend(vim.tbl_keys(servers), {
    'stylua',
  }),
}
require('mason-lspconfig').setup {
  ensure_installed = {},
  automatic_installation = false,
}

-- Fidget (LSP progress indicator)
require('fidget').setup()

-- Register configs and lazily enable servers via FileType autocmds
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

-- LspAttach autocommand for keymaps and built-in completion
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

    -- Document highlight on cursor hold
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

    -- Toggle inlay hints
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end

    -- Built-in completion (replaces nvim-cmp)
    if client and client:supports_method 'textDocument/completion' then
      vim.lsp.completion.enable(true, client.id, event.buf, {
        autotrigger = true,
      })
    end
  end,
})

-- Conform (formatting)
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
  },
}

vim.keymap.set('', '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })

-- Todo comments
require('todo-comments').setup { signs = false }

-- Mini
require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()

-- Treesitter (main branch uses nvim-treesitter.install API)
require('nvim-treesitter').setup {
  ensure_installed = {
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
  },
  auto_install = true,
}

-- Autopairs (no nvim-cmp integration needed with built-in completion)
require('nvim-autopairs').setup {}

-- Lualine
local lualine_auto = require 'lualine.themes.auto'
local colors = {
  rosewater = '#f2d5cf',
  flamingo = '#eebebe',
  pink = '#f4b8e4',
  mauve = '#ca9ee6',
  red = '#e78284',
  maroon = '#ea999c',
  peach = '#ef9f76',
  yellow = '#e5c890',
  green = '#a6d189',
  teal = '#81c8be',
  sky = '#99d1db',
  sapphire = '#85c1dc',
  blue = '#8caaee',
  lavender = '#babbf1',
  text = '#c6d0f5',
  subtext1 = '#b5bfe2',
  subtext0 = '#a5adce',
  overlay2 = '#949cbb',
  overlay1 = '#838ba7',
  overlay0 = '#737994',
  surface2 = '#626880',
  surface1 = '#51576d',
  surface0 = '#414559',
  base = '#303446',
  mantle = '#292c3c',
  crust = '#232634',
}

local function separator()
  return {
    function()
      return '|'
    end,
    color = { fg = colors.surface0, bg = 'NONE', gui = 'bold' },
    padding = { left = 1, right = 1 },
  }
end

local function custom_branch()
  local gitsigns = vim.b.gitsigns_head
  local fugitive = vim.fn.exists '*FugitiveHead' == 1 and vim.fn.FugitiveHead() or ''
  local branch = gitsigns or fugitive
  if branch == nil or branch == '' then
    return ''
  else
    return ' ' .. branch
  end
end

local modes = { 'normal', 'insert', 'visual', 'replace', 'command', 'inactive', 'terminal' }
for _, mode in ipairs(modes) do
  if lualine_auto[mode] and lualine_auto[mode].c then
    lualine_auto[mode].c.bg = 'NONE'
  end
end

require('lualine').setup {
  options = {
    theme = lualine_auto,
    component_separators = '',
    section_separators = '',
    globalstatus = true,
    disabled_filetypes = { statusline = {}, winbar = {} },
  },
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(str)
          return str:sub(1, 1)
        end,
        color = function()
          local mode = vim.fn.mode()
          if mode == '\22' then
            return { fg = 'none', bg = colors.red, gui = 'bold' }
          elseif mode == 'V' then
            return { fg = colors.red, bg = 'none', gui = 'underline,bold' }
          else
            return { fg = colors.red, bg = 'none', gui = 'bold' }
          end
        end,
        padding = { left = 0, right = 0 },
      },
    },
    lualine_b = {
      separator(),
      {
        custom_branch,
        color = { fg = colors.green, bg = 'none', gui = 'bold' },
        padding = { left = 0, right = 0 },
      },
      {
        'diff',
        colored = true,
        diff_color = {
          added = { fg = colors.teal, bg = 'none', gui = 'bold' },
          modified = { fg = colors.yellow, bg = 'none', gui = 'bold' },
          removed = { fg = colors.red, bg = 'none', gui = 'bold' },
        },
        symbols = { added = '+', modified = '~', removed = '-' },
        source = nil,
        padding = { left = 1, right = 0 },
      },
    },
    lualine_c = {
      separator(),
      {
        'filetype',
        icon_only = true,
        colored = false,
        color = { fg = colors.blue, bg = 'none', gui = 'bold' },
        padding = { left = 0, right = 1 },
      },
      {
        'filename',
        file_status = true,
        path = 0,
        shorting_target = 20,
        symbols = {
          modified = '[+]',
          readonly = '[-]',
          unnamed = '[?]',
          newfile = '[!]',
        },
        color = { fg = colors.blue, bg = 'none', gui = 'bold' },
        padding = { left = 0, right = 0 },
      },
      separator(),
      {
        function()
          local bufnr_list = vim.fn.getbufinfo { buflisted = 1 }
          local total = #bufnr_list
          local current_bufnr = vim.api.nvim_get_current_buf()
          local current_index = 0
          for i, buf in ipairs(bufnr_list) do
            if buf.bufnr == current_bufnr then
              current_index = i
              break
            end
          end
          return string.format(' %d/%d', current_index, total)
        end,
        color = { fg = colors.yellow, bg = 'none', gui = 'bold' },
        padding = { left = 0, right = 0 },
      },
    },
    lualine_x = {
      {
        'fileformat',
        color = { fg = colors.yellow, bg = 'none', gui = 'bold' },
        symbols = { unix = '', dos = '', mac = '' },
        padding = { left = 0, right = 0 },
      },
      {
        'encoding',
        color = { fg = colors.yellow, bg = 'none', gui = 'bold' },
        padding = { left = 1, right = 0 },
      },
      separator(),
      {
        function()
          local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
          if size < 0 then
            return '-'
          elseif size < 1024 then
            return size .. 'B'
          elseif size < 1024 * 1024 then
            return string.format('%.1fK', size / 1024)
          elseif size < 1024 * 1024 * 1024 then
            return string.format('%.1fM', size / (1024 * 1024))
          else
            return string.format('%.1fG', size / (1024 * 1024 * 1024))
          end
        end,
        color = { fg = colors.blue, bg = 'none', gui = 'bold' },
        padding = { left = 0, right = 0 },
      },
    },
    lualine_y = {
      separator(),
      {
        'diagnostics',
        sources = { 'nvim_diagnostic', 'coc' },
        sections = { 'error', 'warn', 'info', 'hint' },
        diagnostics_color = {
          error = function()
            local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            return { fg = (count == 0) and colors.green or colors.red, bg = 'none', gui = 'bold' }
          end,
          warn = function()
            local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            return { fg = (count == 0) and colors.green or colors.yellow, bg = 'none', gui = 'bold' }
          end,
          info = function()
            local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
            return { fg = (count == 0) and colors.green or colors.blue, bg = 'none', gui = 'bold' }
          end,
          hint = function()
            local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
            return { fg = (count == 0) and colors.green or colors.teal, bg = 'none', gui = 'bold' }
          end,
        },
        symbols = {
          error = '󰅚 ',
          warn = '󰀪 ',
          info = '󰋽 ',
          hint = '󰌶 ',
        },
        colored = true,
        update_in_insert = false,
        always_visible = true,
        padding = { left = 0, right = 0 },
      },
    },
    lualine_z = {
      separator(),
      {
        'progress',
        color = { fg = colors.red, bg = 'none', gui = 'bold' },
        padding = { left = 0, right = 0 },
      },
      {
        'location',
        color = { fg = colors.red, bg = 'none', gui = 'bold' },
        padding = { left = 1, right = 0 },
      },
    },
  },
}

-- Obsidian
require('obsidian').setup {
  workspaces = {
    {
      name = 'obsidian',
      path = '~/obsidian',
    },
  },
  notes_subdir = 'Areas/Fleeting Notes',
  daily_notes = {
    folder = 'Journal/Weekly',
    date_format = '%Y/%Y-W%W',
    alias_format = '%Y/%Y-W%W',
    default_tags = { 'type/journal' },
    template = 'Resources/Templates/Weekly',
  },
}

-- Render markdown
require('render-markdown').setup {}

-- Database
vim.g.db_ui_use_nerd_fonts = 1

-- Optional: Enable the new UI2 (redesigned message and command-line interface)
-- Uncomment the line below to try it out:
require('vim._core.ui2').enable {}

-- vim: ts=2 sts=2 sw=2 et
