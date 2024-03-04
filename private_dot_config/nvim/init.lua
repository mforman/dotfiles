-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Text wrangling, especially in HTML / JSON
  'tpope/vim-surround',

  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',

  'HiPhish/rainbow-delimiters.nvim',

  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },

  -- Visualise the undo history
  {
    'mbbill/undotree',
    vim.keymap.set('n', '<leader>su', '<Cmd>UndotreeToggle<CR>'),
  },

  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
      'nvim-lua/plenary.nvim',
    }
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context',
    },
    build = ':TSUpdate',
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
        filesystem = {
          hijack_netrw_behavior = "open_current",
        },
        event_handlers = {
          {
            event = "file_opened",
            handler = function(file_path)
              require("neo-tree.command").execute({ action = "close" })
            end
          },

        }
      })
    end,
    vim.keymap.set('n', '<leader>st', '<Cmd>Neotree toggle<CR>'),
    vim.keymap.set('n', '<leader>sT', '<Cmd>Neotree reveal<CR>'),
  },

  {
    'jpalardy/vim-slime',
    config = function()
      vim.cmd([[
		let g:slime_target = "tmux"
			]])
    end
  },

  -- formatting
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          cs = { "csharpier" },
          css = { "prettier" },
          graphql = { "prettier" },
          html = { "prettier" },
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          json = { "prettier" },
          lua = { "stylua" },
          markdown = { "prettier" },
          python = { "black" },
          svelte = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          yaml = { "prettier" },
        },
        formatters = {
          csharpier = {
            command = "dotnet-csharpier",
            args = { "--write-stdout" },
          },
        },
        format_on_save = {
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>df", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
  },


  -- Color Schemes
  { "catppuccin/nvim",       name = "catppuccin" },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
  },

  -- Language-specific plugins
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()

      -- Run gofmt + goimport on save
      local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require('go.format').goimport()
        end,
        group = format_sync_grp,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },

  {
    "jmederosalvarado/roslyn.nvim"
  },

  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Switch for controlling whether you want autoformatting.
      --  Use :KickstartFormatToggle to toggle autoformatting on or off
      local format_is_enabled = true
      vim.api.nvim_create_user_command('KickstartFormatToggle', function()
        format_is_enabled = not format_is_enabled
        print('Setting autoformatting to: ' .. tostring(format_is_enabled))
      end, {})

      -- Create an augroup that is used for managing our formatting autocmds.
      --      We need one augroup per client to make sure that multiple clients
      --      can attach to the same buffer without interfering with each other.
      local _augroups = {}
      local get_augroup = function(client)
        if not _augroups[client.id] then
          local group_name = 'kickstart-lsp-format-' .. client.name
          local id = vim.api.nvim_create_augroup(group_name, { clear = true })
          _augroups[client.id] = id
        end

        return _augroups[client.id]
      end

      -- Whenever an LSP attaches to a buffer, we will run this function.
      --
      -- See `:help LspAttach` for more information about this autocmd event.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach-format', { clear = true }),
        -- This is where we attach the autoformatting for reasonable clients
        callback = function(args)
          local client_id = args.data.client_id
          local client = vim.lsp.get_client_by_id(client_id)
          local bufnr = args.buf

          -- Only attach to clients that support document formatting
          if not client.server_capabilities.documentFormattingProvider then
            return
          end

          -- Tsserver usually works poorly. Sorry you work with bad languages
          -- You can remove this line if you know what you're doing :)
          -- nb: I did remove it because I'm using pmizio/typescript-tools
          -- if client.name == 'tsserver' then
          --   return
          -- end

          -- Create an autocmd that will run *before* we save the buffer.
          --  Run the formatting command for the LSP that has just attached.
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = get_augroup(client),
            buffer = bufnr,
            callback = function()
              if not format_is_enabled then
                return
              end

              vim.lsp.buf.format {
                async = false,
                filter = function(c)
                  return c.id == client.id
                end,
              }
            end,
          })
        end,
      })
    end,
  },
  -- {
  --   "robitx/gp.nvim",
  --   config = function()
  --     require("gp").setup()
  --
  --     -- or setup with your own config (see Install > Configuration in Readme)
  --     -- require("gp").setup(config)
  --
  --     -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
  --     -- VISUAL mode mappings
  --     -- s, x, v modes are handled the same way by which_key
  --     require("which-key").register({
  --       -- ...
  --       ["<C-g>"] = {
  --         c = { ":<C-u>'<,'>GpChatNew<cr>", "Visual Chat New" },
  --         p = { ":<C-u>'<,'>GpChatPaste<cr>", "Visual Chat Paste" },
  --         t = { ":<C-u>'<,'>GpChatToggle<cr>", "Visual Toggle Chat" },
  --
  --         ["<C-x>"] = { ":<C-u>'<,'>GpChatNew split<cr>", "Visual Chat New split" },
  --         ["<C-v>"] = { ":<C-u>'<,'>GpChatNew vsplit<cr>", "Visual Chat New vsplit" },
  --         ["<C-t>"] = { ":<C-u>'<,'>GpChatNew tabnew<cr>", "Visual Chat New tabnew" },
  --
  --         r = { ":<C-u>'<,'>GpRewrite<cr>", "Visual Rewrite" },
  --         a = { ":<C-u>'<,'>GpAppend<cr>", "Visual Append (after)" },
  --         b = { ":<C-u>'<,'>GpPrepend<cr>", "Visual Prepend (before)" },
  --         i = { ":<C-u>'<,'>GpImplement<cr>", "Implement selection" },
  --
  --         g = {
  --           name = "generate into new ..",
  --           p = { ":<C-u>'<,'>GpPopup<cr>", "Visual Popup" },
  --           e = { ":<C-u>'<,'>GpEnew<cr>", "Visual GpEnew" },
  --           n = { ":<C-u>'<,'>GpNew<cr>", "Visual GpNew" },
  --           v = { ":<C-u>'<,'>GpVnew<cr>", "Visual GpVnew" },
  --           t = { ":<C-u>'<,'>GpTabnew<cr>", "Visual GpTabnew" },
  --         },
  --
  --         n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
  --         s = { "<cmd>GpStop<cr>", "GpStop" },
  --         x = { ":<C-u>'<,'>GpContext<cr>", "Visual GpContext" },
  --
  --         w = {
  --           name = "Whisper",
  --           w = { ":<C-u>'<,'>GpWhisper<cr>", "Whisper" },
  --           r = { ":<C-u>'<,'>GpWhisperRewrite<cr>", "Whisper Rewrite" },
  --           a = { ":<C-u>'<,'>GpWhisperAppend<cr>", "Whisper Append (after)" },
  --           b = { ":<C-u>'<,'>GpWhisperPrepend<cr>", "Whisper Prepend (before)" },
  --           p = { ":<C-u>'<,'>GpWhisperPopup<cr>", "Whisper Popup" },
  --           e = { ":<C-u>'<,'>GpWhisperEnew<cr>", "Whisper Enew" },
  --           n = { ":<C-u>'<,'>GpWhisperNew<cr>", "Whisper New" },
  --           v = { ":<C-u>'<,'>GpWhisperVnew<cr>", "Whisper Vnew" },
  --           t = { ":<C-u>'<,'>GpWhisperTabnew<cr>", "Whisper Tabnew" },
  --         },
  --       },
  --       -- ...
  --     }, {
  --       mode = "v", -- VISUAL mode
  --       prefix = "",
  --       buffer = nil,
  --       silent = true,
  --       noremap = true,
  --       nowait = true,
  --     })
  --
  --     -- NORMAL mode mappings
  --     require("which-key").register({
  --       -- ...
  --       ["<C-g>"] = {
  --         c = { "<cmd>GpChatNew<cr>", "New Chat" },
  --         t = { "<cmd>GpChatToggle<cr>", "Toggle Chat" },
  --         f = { "<cmd>GpChatFinder<cr>", "Chat Finder" },
  --
  --         ["<C-x>"] = { "<cmd>GpChatNew split<cr>", "New Chat split" },
  --         ["<C-v>"] = { "<cmd>GpChatNew vsplit<cr>", "New Chat vsplit" },
  --         ["<C-t>"] = { "<cmd>GpChatNew tabnew<cr>", "New Chat tabnew" },
  --
  --         r = { "<cmd>GpRewrite<cr>", "Inline Rewrite" },
  --         a = { "<cmd>GpAppend<cr>", "Append (after)" },
  --         b = { "<cmd>GpPrepend<cr>", "Prepend (before)" },
  --
  --         g = {
  --           name = "generate into new ..",
  --           p = { "<cmd>GpPopup<cr>", "Popup" },
  --           e = { "<cmd>GpEnew<cr>", "GpEnew" },
  --           n = { "<cmd>GpNew<cr>", "GpNew" },
  --           v = { "<cmd>GpVnew<cr>", "GpVnew" },
  --           t = { "<cmd>GpTabnew<cr>", "GpTabnew" },
  --         },
  --
  --         n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
  --         s = { "<cmd>GpStop<cr>", "GpStop" },
  --         x = { "<cmd>GpContext<cr>", "Toggle GpContext" },
  --
  --         w = {
  --           name = "Whisper",
  --           w = { "<cmd>GpWhisper<cr>", "Whisper" },
  --           r = { "<cmd>GpWhisperRewrite<cr>", "Whisper Inline Rewrite" },
  --           a = { "<cmd>GpWhisperAppend<cr>", "Whisper Append (after)" },
  --           b = { "<cmd>GpWhisperPrepend<cr>", "Whisper Prepend (before)" },
  --           p = { "<cmd>GpWhisperPopup<cr>", "Whisper Popup" },
  --           e = { "<cmd>GpWhisperEnew<cr>", "Whisper Enew" },
  --           n = { "<cmd>GpWhisperNew<cr>", "Whisper New" },
  --           v = { "<cmd>GpWhisperVnew<cr>", "Whisper Vnew" },
  --           t = { "<cmd>GpWhisperTabnew<cr>", "Whisper Tabnew" },
  --         },
  --       },
  --       -- ...
  --     }, {
  --       mode = "n", -- NORMAL mode
  --       prefix = "",
  --       buffer = nil,
  --       silent = true,
  --       noremap = true,
  --       nowait = true,
  --     })
  --
  --     -- INSERT mode mappings
  --     require("which-key").register({
  --       -- ...
  --       ["<C-g>"] = {
  --         c = { "<cmd>GpChatNew<cr>", "New Chat" },
  --         t = { "<cmd>GpChatToggle<cr>", "Toggle Chat" },
  --         f = { "<cmd>GpChatFinder<cr>", "Chat Finder" },
  --
  --         ["<C-x>"] = { "<cmd>GpChatNew split<cr>", "New Chat split" },
  --         ["<C-v>"] = { "<cmd>GpChatNew vsplit<cr>", "New Chat vsplit" },
  --         ["<C-t>"] = { "<cmd>GpChatNew tabnew<cr>", "New Chat tabnew" },
  --
  --         r = { "<cmd>GpRewrite<cr>", "Inline Rewrite" },
  --         a = { "<cmd>GpAppend<cr>", "Append (after)" },
  --         b = { "<cmd>GpPrepend<cr>", "Prepend (before)" },
  --
  --         g = {
  --           name = "generate into new ..",
  --           p = { "<cmd>GpPopup<cr>", "Popup" },
  --           e = { "<cmd>GpEnew<cr>", "GpEnew" },
  --           n = { "<cmd>GpNew<cr>", "GpNew" },
  --           v = { "<cmd>GpVnew<cr>", "GpVnew" },
  --           t = { "<cmd>GpTabnew<cr>", "GpTabnew" },
  --         },
  --
  --         x = { "<cmd>GpContext<cr>", "Toggle GpContext" },
  --         s = { "<cmd>GpStop<cr>", "GpStop" },
  --         n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
  --
  --         w = {
  --           name = "Whisper",
  --           w = { "<cmd>GpWhisper<cr>", "Whisper" },
  --           r = { "<cmd>GpWhisperRewrite<cr>", "Whisper Inline Rewrite" },
  --           a = { "<cmd>GpWhisperAppend<cr>", "Whisper Append (after)" },
  --           b = { "<cmd>GpWhisperPrepend<cr>", "Whisper Prepend (before)" },
  --           p = { "<cmd>GpWhisperPopup<cr>", "Whisper Popup" },
  --           e = { "<cmd>GpWhisperEnew<cr>", "Whisper Enew" },
  --           n = { "<cmd>GpWhisperNew<cr>", "Whisper New" },
  --           v = { "<cmd>GpWhisperVnew<cr>", "Whisper Vnew" },
  --           t = { "<cmd>GpWhisperTabnew<cr>", "Whisper Tabnew" },
  --         },
  --       },
  --       -- ...
  --     }, {
  --       mode = "i", -- INSERT mode
  --       prefix = "",
  --       buffer = nil,
  --       silent = true,
  --       noremap = true,
  --       nowait = true,
  --     })
  --   end,
  -- },
  {
    'xvzc/chezmoi.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require("chezmoi").setup {
        -- your configurations
      }
    end
  },

}, {})




-- [[ Setting options ]]
-- See `:help vim.o`

-- Stop losing the cursor
vim.o.guicursor = ""

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.cursorline = true

-- Tab Settings
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

vim.o.smartindent = true

vim.o.wrap = false

-- Hide the mode since it's in lualine
vim.o.showmode = false

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Leave some space
vim.o.scrolloff = 8

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true


-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
-- More context/plugin specific mappings follow after this section
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- HL as amplified versions of hjkl
vim.keymap.set({ 'n', 'v' }, 'H', '0^') -- "beginning of line"
vim.keymap.set({ 'n', 'v' }, 'L', '$')  --"end of line" ,

-- Jump around
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Move selected text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Don't lose the paste buffer when deleting
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Copy to the system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Browse command for git-fugitive
vim.api.nvim_create_user_command(
  'Browse',
  function(opts)
    vim.fn.system { 'open', opts.fargs[1] }
  end,
  { nargs = 1 }
)


-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
  pickers = {
    find_files = {
      -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
      -- `-L` follows symlinks
      find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "-L" },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>sS', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })


-- [[ Configure Harpoon ]]
local harpoon = require("harpoon")

harpoon:setup()
vim.keymap.set("n", "<leader>z", function() harpoon:list():append() end, { desc = 'Append to Harpoon' })
vim.keymap.set("n", "<leader>ss", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
  { desc = 'Toggle Harpoon Menu' })

-- QWERTY
vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end, { desc = 'Harpoon 1' })
vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end, { desc = 'Harpoon 2' })
vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end, { desc = 'Harpoon 3' })
vim.keymap.set("n", "<C-;>", function() harpoon:list():select(4) end, { desc = 'Harpoon 4' })

-- Colemak
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(1) end, { desc = 'Harpoon 1' })
vim.keymap.set("n", "<C-e>", function() harpoon:list():select(2) end, { desc = 'Harpoon 2' })
vim.keymap.set("n", "<C-i>", function() harpoon:list():select(3) end, { desc = 'Harpoon 3' })
vim.keymap.set("n", "<C-o>", function() harpoon:list():select(4) end, { desc = 'Harpoon 4' })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'c_sharp', 'cpp', 'go', 'lua', 'markdown', 'python', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)


-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', function()
    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
  end, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Configure border on floating windows.
vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
})

require('lspconfig.ui.windows').default_options.border = "double"

-- document existing keychains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup({
  ui = {
    icons = {
      package_installed = ' ',
      package_pending = ' ',
      package_uninstalled = ' ',
    },
    border = 'rounded',
  },
})
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  eslint = { packageManager = 'npm', },
  -- gopls = {},
  html = {
    filetypes = { 'html', 'twig', 'hbs' },
    html = {
      format = {
        contentUnformatted = "pre, code, textarea, div",
        templating = true,
        wrapLineLength = 120,
        wrapAttributes = 'auto',
      },
      hover = {
        documentation = true,
        references = true,
      },
    },
  },
  marksman = {},
  -- omnisharp = {},
  pyright = {},
  tsserver = {},
  -- volar = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

require("roslyn").setup({
  on_attach = on_attach,
  capabilities = capabilities
})

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- [[ Configure status bar ]]
require('lualine').setup {
  options = {
    component_separators = '',
    section_separators = '',
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
  },
  sections = {
    lualine_c = {
      {
        'filename',
        path = 3,
        shorting_target = 20,
      }
    },
  },
}


-- [[ Configure Colors ]]
require("catppuccin").setup({
  custom_highlights = function(colors)
    return {
      LineNr = { fg = colors.overlay1 }
    }
  end
})

function ColorMyPencils(color)
  color = color or 'catppuccin'
  vim.cmd.colorscheme(color)
end

ColorMyPencils()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
