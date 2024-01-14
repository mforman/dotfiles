local wezterm = require("wezterm")
local act = wezterm.action

local shortcuts = {}

local map = function(key, mods, action)
    if type(mods) == "string" then
        table.insert(shortcuts, { key = key, mods = mods, action = action })
    elseif type(mods) == "table" then
        for _, mod in pairs(mods) do
            table.insert(shortcuts, { key = key, mods = mod, action = action })
        end
    end
end

-- Can we do without tmux?
map("\\", "LEADER", act.SplitHorizontal { domain = 'CurrentPaneDomain' })
map("-", "LEADER", act.SplitVertical { domain = 'CurrentPaneDomain' })

map("z", "LEADER", act.TogglePaneZoomState)

map("s", "LEADER", act.ShowLauncherArgs { flags = "DOMAINS|WORKSPACES" })
map("$", "LEADER", act.PromptInputLine {
    description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Rename workspace' },
    },
    action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
            wezterm.mux.rename_workspace(
                wezterm.mux.get_active_workspace(),
                line
            )
        end
    end)
})

local M = {}
M.apply = function(c)
    c.leader = {
        key = "a",
        mods = "CTRL",
        timeout_milliseconds = 5000,
    }
    c.keys = shortcuts
    -- c.disable_default_key_bindings = true
    -- c.key_tables = key_tables
    -- c.mouse_bindings = {
    --   {
    --     event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    --     mods = "NONE",
    --     action = wezterm.action.ScrollByLine(5),
    --   },
    --   {
    --     event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    --     mods = "NONE",
    --     action = wezterm.action.ScrollByLine(-5),
    --   },
    -- }
end
return M
