if not os.getenv 'OPENAI_API_BASE' then
  return {}
end

return {
  {
    'robitx/gp.nvim',
    config = function()
      local conf = {
        -- For customization, refer to Install > Configuration in the Documentation/Readme
        providers = {
          openai = {},
          azure = {
            disable = false,
            endpoint = os.getenv 'OPENAI_API_BASE' .. '/openai/deployments/{{model}}/chat/completions?api-version=2024-08-01-preview',
            secret = os.getenv 'OPENAI_API_KEY',
          },
        },
        agents = {
          {
            provider = 'azure',
            name = 'ChatGPT4o',
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = 'gpt-4o', temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require('gp.defaults').chat_system_prompt,
          },
        },
        -- default agent names set during startup, if nil last used agent is used
        default_command_agent = 'ChatGPT4o',
        default_chat_agent = 'ChatGPT4o',
      }
      require('gp').setup(conf)
      -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
      require('which-key').add {
        -- VISUAL mode mappings
        -- s, x, v modes are handled the same way by which_key
        {
          mode = { 'v' },
          nowait = true,
          remap = false,
          { '<C-g><C-t>', ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = 'ChatNew tabnew' },
          { '<C-g><C-v>', ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = 'ChatNew vsplit' },
          { '<C-g><C-x>', ":<C-u>'<,'>GpChatNew split<cr>", desc = 'ChatNew split' },
          { '<C-g>a', ":<C-u>'<,'>GpAppend<cr>", desc = 'Visual Append (after)' },
          { '<C-g>b', ":<C-u>'<,'>GpPrepend<cr>", desc = 'Visual Prepend (before)' },
          { '<C-g>c', ":<C-u>'<,'>GpChatNew<cr>", desc = 'Visual Chat New' },
          { '<C-g>g', group = 'generate into new ..' },
          { '<C-g>ge', ":<C-u>'<,'>GpEnew<cr>", desc = 'Visual GpEnew' },
          { '<C-g>gn', ":<C-u>'<,'>GpNew<cr>", desc = 'Visual GpNew' },
          { '<C-g>gp', ":<C-u>'<,'>GpPopup<cr>", desc = 'Visual Popup' },
          { '<C-g>gt', ":<C-u>'<,'>GpTabnew<cr>", desc = 'Visual GpTabnew' },
          { '<C-g>gv', ":<C-u>'<,'>GpVnew<cr>", desc = 'Visual GpVnew' },
          { '<C-g>i', ":<C-u>'<,'>GpImplement<cr>", desc = 'Implement selection' },
          { '<C-g>n', '<cmd>GpNextAgent<cr>', desc = 'Next Agent' },
          { '<C-g>p', ":<C-u>'<,'>GpChatPaste<cr>", desc = 'Visual Chat Paste' },
          { '<C-g>r', ":<C-u>'<,'>GpRewrite<cr>", desc = 'Visual Rewrite' },
          { '<C-g>s', '<cmd>GpStop<cr>', desc = 'GpStop' },
          { '<C-g>t', ":<C-u>'<,'>GpChatToggle<cr>", desc = 'Visual Toggle Chat' },
          { '<C-g>x', ":<C-u>'<,'>GpContext<cr>", desc = 'Visual GpContext' },
        },

        -- NORMAL mode mappings
        {
          mode = { 'n' },
          nowait = true,
          remap = false,
          { '<C-g><C-t>', '<cmd>GpChatNew tabnew<cr>', desc = 'New Chat tabnew' },
          { '<C-g><C-v>', '<cmd>GpChatNew vsplit<cr>', desc = 'New Chat vsplit' },
          { '<C-g><C-x>', '<cmd>GpChatNew split<cr>', desc = 'New Chat split' },
          { '<C-g>a', '<cmd>GpAppend<cr>', desc = 'Append (after)' },
          { '<C-g>b', '<cmd>GpPrepend<cr>', desc = 'Prepend (before)' },
          { '<C-g>c', '<cmd>GpChatNew<cr>', desc = 'New Chat' },
          { '<C-g>f', '<cmd>GpChatFinder<cr>', desc = 'Chat Finder' },
          { '<C-g>g', group = 'generate into new ..' },
          { '<C-g>ge', '<cmd>GpEnew<cr>', desc = 'GpEnew' },
          { '<C-g>gn', '<cmd>GpNew<cr>', desc = 'GpNew' },
          { '<C-g>gp', '<cmd>GpPopup<cr>', desc = 'Popup' },
          { '<C-g>gt', '<cmd>GpTabnew<cr>', desc = 'GpTabnew' },
          { '<C-g>gv', '<cmd>GpVnew<cr>', desc = 'GpVnew' },
          { '<C-g>n', '<cmd>GpNextAgent<cr>', desc = 'Next Agent' },
          { '<C-g>r', '<cmd>GpRewrite<cr>', desc = 'Inline Rewrite' },
          { '<C-g>s', '<cmd>GpStop<cr>', desc = 'GpStop' },
          { '<C-g>t', '<cmd>GpChatToggle<cr>', desc = 'Toggle Chat' },
          { '<C-g>x', '<cmd>GpContext<cr>', desc = 'Toggle GpContext' },
        },

        -- INSERT mode mappings
        {
          mode = { 'i' },
          nowait = true,
          remap = false,
          { '<C-g><C-t>', '<cmd>GpChatNew tabnew<cr>', desc = 'New Chat tabnew' },
          { '<C-g><C-v>', '<cmd>GpChatNew vsplit<cr>', desc = 'New Chat vsplit' },
          { '<C-g><C-x>', '<cmd>GpChatNew split<cr>', desc = 'New Chat split' },
          { '<C-g>a', '<cmd>GpAppend<cr>', desc = 'Append (after)' },
          { '<C-g>b', '<cmd>GpPrepend<cr>', desc = 'Prepend (before)' },
          { '<C-g>c', '<cmd>GpChatNew<cr>', desc = 'New Chat' },
          { '<C-g>f', '<cmd>GpChatFinder<cr>', desc = 'Chat Finder' },
          { '<C-g>g', group = 'generate into new ..' },
          { '<C-g>ge', '<cmd>GpEnew<cr>', desc = 'GpEnew' },
          { '<C-g>gn', '<cmd>GpNew<cr>', desc = 'GpNew' },
          { '<C-g>gp', '<cmd>GpPopup<cr>', desc = 'Popup' },
          { '<C-g>gt', '<cmd>GpTabnew<cr>', desc = 'GpTabnew' },
          { '<C-g>gv', '<cmd>GpVnew<cr>', desc = 'GpVnew' },
          { '<C-g>n', '<cmd>GpNextAgent<cr>', desc = 'Next Agent' },
          { '<C-g>r', '<cmd>GpRewrite<cr>', desc = 'Inline Rewrite' },
          { '<C-g>s', '<cmd>GpStop<cr>', desc = 'GpStop' },
          { '<C-g>t', '<cmd>GpChatToggle<cr>', desc = 'Toggle Chat' },
          { '<C-g>x', '<cmd>GpContext<cr>', desc = 'Toggle GpContext' },
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
