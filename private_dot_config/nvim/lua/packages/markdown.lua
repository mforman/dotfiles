local gh = require('core.util').gh

return {
  plugins = {
    { src = gh 'obsidian-nvim/obsidian.nvim' },
    { src = gh 'MeanderingProgrammer/render-markdown.nvim' },
  },
  setup = function()
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

    require('render-markdown').setup {}
  end,
}

-- vim: ts=2 sts=2 sw=2 et
