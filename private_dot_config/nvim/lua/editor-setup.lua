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
    pickers = {
      colorscheme = {
        enable_preview = true
      },
      find_files = {
        -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
        -- `-L` follows symlinks
        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "-L" },
      },
    },
  },
  extensions = {
    undo = {
      side_by_side = true,
      layout_strategy = "vertical",
      layout_config = {
        preview_height = 0.8,
      }
    }
  }
}

require("telescope").load_extension("undo")

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
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = { git_root },
    })
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

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = 'Search [U]ndo history' })

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

-- vim: ts=2 sts=2 sw=2 et
