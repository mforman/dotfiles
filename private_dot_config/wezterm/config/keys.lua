local wezterm = require("wezterm")
local act = wezterm.action

-- -- Functions
-- local get_last_folder_segment = function(cwd)
--     if cwd == nil then
--         return "N/A" -- or some default value you prefer
--     end
--
--     -- Strip off 'file:///' if present
--     local pathStripped = cwd:match("^file:///(.+)") or cwd
--     -- Normalize backslashes to slashes for Windows paths
--     pathStripped = pathStripped:gsub("\\", "/")
--     -- Split the path by '/'
--     local path = {}
--     for segment in string.gmatch(pathStripped, "[^/]+") do
--         table.insert(path, segment)
--     end
--     return path[#path] -- returns the last segment
-- end
--
-- local function get_current_working_dir(tab)
--     local current_dir = tab.active_pane.current_working_dir or ''
--     return get_last_folder_segment(current_dir)
-- end

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

-- Panes
map("\\", "LEADER", act.SplitHorizontal({ domain = "CurrentPaneDomain" }))
map("-", "LEADER", act.SplitVertical({ domain = "CurrentPaneDomain" }))
map("z", "LEADER", act.TogglePaneZoomState)
map("0", "LEADER", act.PaneSelect({ mode = "SwapWithActive" }))
map("Space", "LEADER", act.RotatePanes("Clockwise"))
map("LeftArrow", "LEADER", act.ActivatePaneDirection("Left"))
map("RightArrow", "LEADER", act.ActivatePaneDirection("Right"))
map("UpArrow", "LEADER", act.ActivatePaneDirection("Up"))
map("DownArrow", "LEADER", act.ActivatePaneDirection("Down"))

map("LeftArrow", "LEADER|CTRL", act.ActivatePaneDirection("Left"))
map("RightArrow", "LEADER|CTRL", act.ActivatePaneDirection("Right"))
map("UpArrow", "LEADER|CTRL", act.ActivatePaneDirection("Up"))
map("DownArrow", "LEADER|CTRL", act.ActivatePaneDirection("Down"))

-- Tabs
map("c", "LEADER", act.SpawnTab("CurrentPaneDomain"))
map("w", "LEADER", act.ShowTabNavigator)
-- Quick tab movement
for i = 1, 9 do
  map(tostring(i), "LEADER", act.ActivateTab(i - 1))
  map(tostring(i), "LEADER|CTRL", act.MoveTab(i - 1))
end

-- Other Config
map("s", "LEADER", act.ShowLauncherArgs({ flags = "WORKSPACES" }))
map(
  "$",
  "LEADER",
  act.PromptInputLine({
    description = wezterm.format({
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { AnsiColor = "Fuchsia" } },
      { Text = "Rename workspace" },
    }),
    action = wezterm.action_callback(function(window, pane, line)
      -- line will be `nil` if they hit escape without entering anything
      -- An empty string if they just hit enter
      -- Or the actual line of text they wrote
      if line then
        wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
      end
    end),
  })
)
map(
  ",",
  "LEADER",
  act.PromptInputLine({
    description = "Enter a new name for tab",
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:active_tab():set_title(line)
      end
    end),
  })
)

map("a", "LEADER|CTRL", act.SendKey({ key = "a", mods = "CTRL" }))

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
