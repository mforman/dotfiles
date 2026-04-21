local wezterm = require("wezterm")

local config = {}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  config.default_domain = "WSL:Ubuntu"
  config.launch_menu = {
    { label = "New tab - WSL", domain = { DomainName = "WSL:Ubuntu" } },
    { label = "New tab - PowerShell", domain = { DomainName = "local" }, args = { "pwsh" } },
  }
end

config.automatically_reload_config = true

config.font = wezterm.font_with_fallback({ "Hack Nerd Font" })
config.font_size = 15
config.color_scheme = "Catppuccin Macchiato"
config.default_cursor_style = "SteadyBlock"

config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.4,
}

config.window_decorations = "TITLE|RESIZE"
config.warn_about_missing_glyphs = false
config.hide_tab_bar_if_only_one_tab = true

-- Left Option = Meta/Alt for terminal apps; Right Option stays as compose
-- so accented characters (Option+E, Option+U, etc.) still work.
config.send_composed_key_when_left_alt_is_pressed = false

config.keys = {
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b\r") },
}

return config
