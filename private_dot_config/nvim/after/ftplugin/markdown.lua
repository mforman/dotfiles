-- Ensure the markdown file type is detected
vim.bo.filetype = 'markdown'

-- Enable spell checking
vim.wo.spell = true
vim.bo.spelllang = 'en_gb,en_us'

-- Set wrap and linebreak for a better text editing experience
vim.wo.wrap = true
vim.wo.linebreak = true

-- Custom key mappings for Markdown
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>p', '<Plug>MarkdownPreview', { noremap = true, silent = true })
