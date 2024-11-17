-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action


-- This table will hold the configuration
local config = {}
config.launch_menu = {}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
	config.default_domain = 'WSL:Ubuntu'
  table.insert(config.launch_menu, {
    label = 'New tab - WSL',
    domain = { DomainName = 'WSL:Ubuntu' },
  })
	table.insert(config.launch_menu, {
		label = 'New tab - PowerShell',
		domain = { DomainName = 'local' },
		args = { 'pwsh' },
	})
end

config.automatically_reload_config = true


-- Fonts and Colors
config.font = wezterm.font_with_fallback { "Hack Nerd Font" }
{{ if eq .chezmoi.os "darwin" }}
config.font_size = 16.5
{{ else }}
config.font_size = 12
{{ end }}
config.color_scheme = 'Catppuccin Mocha'
config.default_cursor_style = 'SteadyBlock'

config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.4,
}

-- General
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
config.warn_about_missing_glyphs = false

local use_native_mux = true
if use_native_mux then
	require("config.keys").apply(config)

	-- Replicate the status line in the tab bar
	require("config.bar").apply_to_config(config, {
		dividers = "rounded", -- "slant_right", "slant_left", "arrows", "rounded", false
		tabs = {
			pane_count = "icon"
		},
		clock = {
			enabled = true,
			format = " %Y-%m-%d %H:%M "
		}
	})
	config.hide_tab_bar_if_only_one_tab = false
else
	config.hide_tab_bar_if_only_one_tab = true
end

-- and finally, return the configuration to wezterm
return config
