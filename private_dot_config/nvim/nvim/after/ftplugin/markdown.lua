-- Ensure the markdown file type is detected
vim.bo.filetype = 'markdown'

-- Enable spell checking
vim.wo.spell = true
vim.bo.spelllang = 'en_gb,en_us'

-- Set wrap and linebreak for a better text editing experience
vim.wo.wrap = true
vim.wo.linebreak = true

-- Custom key mappings for Markdown
-- These mappings are examples. Feel free to adjust them according to your preferences.
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>p', '<Plug>MarkdownPreview', { noremap = true, silent = true })

-- Markdown preview plugin (for example, markdown-preview.nvim)
-- Make sure to follow the plugin's installation instructions
-- vim.cmd [[let g:mkdp_auto_start = 1]]

-- This setup provides a basic enhancement for Markdown editing in Neovim, including spell checking, convenient wrapping of lines, syntax highlighting through Treesitter, and simple key mappings for toggling task list items. Depending on your workflow, you might want to integrate additional tools or plugins, such as a Markdown linting tool, or configure more complex key mappings and commands.
