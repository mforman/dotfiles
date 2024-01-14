-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.automatically_reload_config = true

-- Fonts and Colors
config.font = wezterm.font("DMMono Nerd Font")
config.font_size = 16.5

config.color_scheme = 'Catppuccin Mocha'

config.hide_tab_bar_if_only_one_tab = true

config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- require("config.keys").apply(config)

-- Replicate the status line in the tab bar
-- require("config.bar").apply_to_config(config, {
--     dividers = "rounded", -- "slant_right", "slant_left", "arrows", "rounded", false
--     clock = {
--         enabled = true,
--         format = " %Y-%m-%d %H:%M"
--     }
-- })

-- and finally, return the configuration to wezterm
return config
