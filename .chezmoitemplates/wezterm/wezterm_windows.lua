-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action


-- This table will hold the configuration
local config = {}
config.launch_menu = {}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
	table.insert(config.launch_menu, {
		label = 'New Tab (domain `PowerShell`)',
		domain = { DomainName = 'local' },
		args = { 'pwsh' },
	})
end

config.automatically_reload_config = true
config.default_domain = 'WSL:Ubuntu'


-- Fonts and Colors
config.font = wezterm.font("DMMono Nerd Font")
config.font_size = 12.5

config.color_scheme = 'Catppuccin Mocha'


-- General
-- config.hide_tab_bar_if_only_one_tab = true

config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

require("config.keys").apply(config)

-- Replicate the status line in the tab bar
require("config.bar").apply_to_config(config, {
	dividers = "rounded", -- "slant_right", "slant_left", "arrows", "rounded", false
	clock = {
		enabled = true,
		format = " %Y-%m-%d %H:%M "
	}
})


local function get_current_working_dir(tab)
	local current_dir = tab.active_pane.current_working_dir
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	return current_dir == HOME_DIR and "." or string.gsub(current_dir, "(.*[/\\])(.*)", "%2")
end


wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
	local has_unseen_output = false
	local is_zoomed = false

	for _, pane in ipairs(tab.panes) do
		if not tab.is_active and pane.has_unseen_output then
			has_unseen_output = true
		end
		if pane.is_zoomed then
			is_zoomed = true
		end
	end

	local cwd = get_current_working_dir(tab)
	local process = get_process(tab)
	local zoom_icon = is_zoomed and wezterm.nerdfonts.cod_zoom_in or ""
	local title = string.format(' %s ~ %s %s ', process, cwd, zoom_icon) -- Add placeholder for zoom_icon

	return wezterm.format({
		{ Attribute = { Intensity = 'Bold' } },
		{ Text = title }
	})
end)

-- and finally, return the configuration to wezterm
return config
