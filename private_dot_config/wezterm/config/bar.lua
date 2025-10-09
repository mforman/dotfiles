local wezterm = require("wezterm")

local M = {}

-- default configuration
local config = {
  position = "bottom",
  max_width = 32,
  dividers = "slant_right",
  indicator = {
    leader = {
      enabled = true,
      off = " ",
      on = " ",
    },
    mode = {
      enabled = true,
      names = {
        resize_mode = "RESIZE",
        copy_mode = "VISUAL",
        search_mode = "SEARCH",
      },
    },
  },
  tabs = {
    numerals = "arabic",
    pane_count = "superscript",
    brackets = {
      active = { "", ":" },
      inactive = { "", ":" },
    },
  },
  clock = {
    enabled = true,
    format = "%H:%M",
  },
}

-- parsed config
local C = {}

local function tableMerge(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        tableMerge(t1[k] or {}, t2[k] or {})
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end

local dividers = {
  slant_right = {
    left = utf8.char(0xe0be),
    right = utf8.char(0xe0bc),
  },
  slant_left = {
    left = utf8.char(0xe0ba),
    right = utf8.char(0xe0b8),
  },
  arrows = {
    left = utf8.char(0xe0b2),
    right = utf8.char(0xe0b0),
  },
  rounded = {
    left = utf8.char(0xe0b6),
    right = utf8.char(0xe0b4),
  },
}

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
-- exporting an apply_to_config function, even though we don't change the users config
M.apply_to_config = function(c, opts)
  -- make the opts arg optional
  if not opts then
    opts = {}
  end

  -- combine user config with defaults
  config = tableMerge(config, opts)
  C.div = {
    l = "",
    r = "",
  }

  if config.dividers then
    C.div.l = dividers[config.dividers].left
    C.div.r = dividers[config.dividers].right
  end

  C.leader = {
    enabled = config.indicator.leader.enabled and true,
    off = config.indicator.leader.off,
    on = config.indicator.leader.on,
  }

  C.mode = {
    enabled = config.indicator.mode.enabled,
    names = config.indicator.mode.names,
  }

  C.tabs = {
    numerals = config.tabs.numerals,
    pane_count_style = config.tabs.pane_count,
    brackets = {
      active = config.tabs.brackets.active,
      inactive = config.tabs.brackets.inactive,
    },
  }

  C.clock = {
    enabled = config.clock.enabled,
    format = config.clock.format,
  }

  -- set the right-hand padding to 0 spaces, if the rounded style is active
  C.p = (config.dividers == "rounded") and "" or " "

  -- set wezterm config options according to the parsed config
  c.use_fancy_tab_bar = false
  c.tab_bar_at_bottom = config.position == "bottom"
  c.tab_max_width = config.max_width
end

-- superscript/subscript
local function numberStyle(number, script)
  local scripts = {
    superscript = {
      "⁰",
      "¹",
      "²",
      "³",
      "⁴",
      "⁵",
      "⁶",
      "⁷",
      "⁸",
      "⁹",
    },
    subscript = {
      "₀",
      "₁",
      "₂",
      "₃",
      "₄",
      "₅",
      "₆",
      "₇",
      "₈",
      "₉",
    },
  }
  local numbers = scripts[script]
  local number_string = tostring(number)
  local result = ""
  for i = 1, #number_string do
    local char = number_string:sub(i, i)
    local num = tonumber(char)
    if num then
      result = result .. numbers[num + 1]
    else
      result = result .. char
    end
  end
  return result
end

local roman_numerals = {
  "Ⅰ",
  "Ⅱ",
  "Ⅲ",
  "Ⅳ",
  "Ⅴ",
  "Ⅵ",
  "Ⅶ",
  "Ⅷ",
  "Ⅸ",
  "Ⅹ",
  "Ⅺ",
  "Ⅻ",
}

-- Functions
local get_last_folder_segment = function(cwd)
  if cwd == nil then
    return "N/A" -- or some default value you prefer
  end

  -- Strip off 'file:///' if present
  local pathStripped = cwd:match("^file:///(.+)") or cwd
  -- Normalize backslashes to slashes for Windows paths
  pathStripped = pathStripped:gsub("\\", "/")
  -- Split the path by '/'
  local path = {}
  for segment in string.gmatch(pathStripped, "[^/]+") do
    table.insert(path, segment)
  end
  return path[#path] -- returns the last segment
end

local function get_current_working_dir(tab)
  local current_dir = tab.active_pane.current_working_dir or ""
  return get_last_folder_segment(current_dir)
end

local process_icons = {
  ["brew"] = wezterm.nerdfonts.fa_beer,
  ["colima"] = wezterm.nerdfonts.linux_docker,
  ["docker"] = wezterm.nerdfonts.linux_docker,
  ["docker-compose"] = wezterm.nerdfonts.linux_docker,
  ["psql"] = wezterm.nerdfonts.dev_postgresql,
  ["kuberlr"] = wezterm.nerdfonts.linux_docker,
  ["kubectl"] = wezterm.nerdfonts.linux_docker,
  ["stern"] = wezterm.nerdfonts.linux_docker,
  ["k9s"] = wezterm.nerdfonts.md_kubernetes,
  ["nvim"] = wezterm.nerdfonts.custom_neovim,
  ["make"] = wezterm.nerdfonts.seti_makefile,
  ["vim"] = wezterm.nerdfonts.dev_vim,
  ["go"] = wezterm.nerdfonts.seti_go,
  ["~"] = wezterm.nerdfonts.dev_terminal,
  ["fish"] = wezterm.nerdfonts.dev_terminal,
  ["zsh"] = wezterm.nerdfonts.dev_terminal,
  ["bash"] = wezterm.nerdfonts.cod_terminal_bash,
  ["btm"] = wezterm.nerdfonts.mdi_chart_donut_variant,
  ["htop"] = wezterm.nerdfonts.mdi_chart_donut_variant,
  ["cargo"] = wezterm.nerdfonts.dev_rust,
  ["sudo"] = wezterm.nerdfonts.fa_hashtag,
  ["lazydocker"] = wezterm.nerdfonts.linux_docker,
  ["lazygit"] = wezterm.nerdfonts.dev_git,
  ["git"] = wezterm.nerdfonts.dev_git,
  ["lua"] = wezterm.nerdfonts.seti_lua,
  ["wget"] = wezterm.nerdfonts.mdi_arrow_down_box,
  ["curl"] = wezterm.nerdfonts.mdi_flattr,
  ["gh"] = wezterm.nerdfonts.dev_github_badge,
  ["ruby"] = wezterm.nerdfonts.cod_ruby,
  ["python"] = wezterm.nerdfonts.cod_dev_python,
  ["poetry"] = wezterm.nerdfonts.cod_dev_python,
  ["pwsh"] = wezterm.nerdfonts.seti_powershell,
  ["cmd"] = wezterm.nerdfonts.seti_powershell,
  ["node"] = wezterm.nerdfonts.dev_nodejs_small,
  ["npm"] = wezterm.nerdfonts.dev_nodejs_small,
  ["dotnet"] = wezterm.nerdfonts.md_language_csharp,
  ["wslhost"] = wezterm.nerdfonts.cod_terminal_ubuntu,
}
local function get_process(tab)
  -- Match either `appname` (without .exe) or `appname.exe` followed by optional path
  local process_name = tab.active_pane.title:lower():match("([^%s/\\]+)%.exe") -- Matches `appname.exe`
    or tab.active_pane.title:match("^([^%s/\\]+)") -- Matches `appname`

  local user_name = tab.tab_title:match("^([^%s/\\]+)%.exe") -- Matches `appname.exe`
    or tab.tab_title:match("^([^%s/\\]+)") -- Matches `appname`

  -- Strip trailing .exe if needed (it won't match the second condition if .exe is not there)
  process_name = process_name:gsub("%.exe$", "")

  local icon = process_icons[user_name] or process_icons[process_name] or string.format("[%s]", process_name)
  -- local icon = process_icons[process_name] or wezterm.nerdfonts.seti_checkbox_unchecked

  return icon
  -- return string.format('%s %s ', icon, process_name)
end

local function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end
-- custom tab bar
wezterm.on("format-tab-title", function(tab, tabs, _panes, conf, _hover, _max_width)
  local colours = conf.resolved_palette.tab_bar

  local active_tab_index = 0
  for _, t in ipairs(tabs) do
    if t.is_active == true then
      active_tab_index = t.tab_index
    end
  end

  -- TODO: make colors configurable
  local rainbow = {
    conf.resolved_palette.ansi[2],
    conf.resolved_palette.indexed[16],
    conf.resolved_palette.ansi[4],
    conf.resolved_palette.ansi[3],
    conf.resolved_palette.ansi[5],
    conf.resolved_palette.ansi[6],
  }

  local i = tab.tab_index % 6
  local active_bg = rainbow[i + 1]
  local active_fg = colours.background
  local inactive_bg = colours.inactive_tab.bg_color
  local inactive_fg = colours.inactive_tab.fg_color
  local new_tab_bg = colours.new_tab.bg_color

  local s_bg, s_fg, e_bg, e_fg

  -- the last tab
  if tab.tab_index == #tabs - 1 then
    if tab.is_active then
      s_bg = active_bg
      s_fg = active_fg
      e_bg = new_tab_bg
      e_fg = active_bg
    else
      s_bg = inactive_bg
      s_fg = inactive_fg
      e_bg = new_tab_bg
      e_fg = inactive_bg
    end
  elseif tab.tab_index == active_tab_index - 1 then
    s_bg = inactive_bg
    s_fg = inactive_fg
    e_bg = rainbow[(i + 1) % 6 + 1]
    e_fg = inactive_bg
  elseif tab.is_active then
    s_bg = active_bg
    s_fg = active_fg
    e_bg = inactive_bg
    e_fg = active_bg
  else
    s_bg = inactive_bg
    s_fg = inactive_fg
    e_bg = inactive_bg
    e_fg = inactive_bg
  end

  local pane_count = ""
  if C.tabs.pane_count_style then
    local tabi = wezterm.mux.get_tab(tab.tab_id)
    local muxpanes = tabi:panes()
    local count = #muxpanes == 1 and "" or tostring(#muxpanes)
    if C.tabs.pane_count_style == "icon" then
      if #muxpanes > 1 then
        if tab.active_pane.is_zoomed then
          pane_count = string.format(" %s ", wezterm.nerdfonts.md_arrow_expand_all)
        else
          pane_count = string.format(" %s ", wezterm.nerdfonts.cod_terminal_tmux)
        end
      end
    else
      pane_count = numberStyle(count, C.tabs.pane_count_style)
    end
  end

  local index_i
  if C.tabs.numerals == "roman" then
    index_i = roman_numerals[tab.tab_index + 1]
  else
    index_i = tab.tab_index + 1
  end

  local index
  if tab.is_active then
    index = string.format("%s%s%s ", C.tabs.brackets.active[1], index_i, C.tabs.brackets.active[2])
  else
    index = string.format("%s%s%s ", C.tabs.brackets.inactive[1], index_i, C.tabs.brackets.inactive[2])
  end

  -- start and end hardcoded numbers are the Powerline + " " padding
  local fillerwidth = 2 + string.len(index) + string.len(pane_count) + 2
  local tabtitle = tab.active_pane.title
  local user_title = tab.tab_title
  if user_title and #user_title > 0 then
    tabtitle = user_title
  end
  local icon = get_process(tab)
  if icon and #icon > 0 then
    tabtitle = string.format("%s %s", icon, tabtitle)
  end
  local width = conf.tab_max_width - fillerwidth - 1
  if (#tabtitle + fillerwidth) > conf.tab_max_width then
    tabtitle = wezterm.truncate_right(tabtitle, width) .. "…"
  end

  local title = string.format(" %s%s%s%s", index, tabtitle, pane_count, C.p)

  return {
    { Background = { Color = s_bg } },
    { Foreground = { Color = s_fg } },
    { Text = title },
    { Background = { Color = e_bg } },
    { Foreground = { Color = e_fg } },
    { Text = C.div.r },
  }
end)

wezterm.on("update-status", function(window, _pane)
  local active_kt = window:active_key_table() ~= nil
  local show = C.leader.enabled or (active_kt and C.mode.enabled)
  if not show then
    window:set_left_status("")
    return
  end

  local present, conf = pcall(window.effective_config, window)
  if not present then
    return
  end
  local palette = conf.resolved_palette
  local colours = palette.tab_bar

  local leader = ""
  if C.leader.enabled then
    local leader_text = C.leader.off
    if window:leader_is_active() then
      leader_text = C.leader.on
    end
    leader = wezterm.format({
      { Foreground = { Color = palette.background } },
      { Background = { Color = palette.ansi[5] } },
      { Text = " " .. leader_text .. C.p },
    })
  end

  local mode = ""
  if C.mode.enabled then
    local mode_text = ""
    local active = window:active_key_table()
    if C.mode.names[active] ~= nil then
      mode_text = C.mode.names[active] .. ""
    end
    mode = wezterm.format({
      { Foreground = { Color = palette.background } },
      { Background = { Color = palette.ansi[5] } },
      { Attribute = { Intensity = "Bold" } },
      { Text = mode_text },
      "ResetAttributes",
    })
  end

  local first_tab_active = window:mux_window():tabs_with_info()[1].is_active
  local divider_bg = first_tab_active and palette.ansi[2] or palette.tab_bar.inactive_tab.bg_color

  local divider = wezterm.format({
    { Background = { Color = divider_bg } },
    { Foreground = { Color = palette.ansi[5] } },
    { Text = C.div.r },
  })

  window:set_left_status(leader .. mode .. divider)

  local R = {}
  table.insert(R, { Background = { Color = palette.tab_bar.background } })
  table.insert(R, { Foreground = { Color = colours.inactive_tab.fg_color } })
  -- table.insert(R, { Text = window.active_workspace() })
  if C.clock.enabled then
    local time = wezterm.time.now():format(C.clock.format)
    table.insert(R, { Background = { Color = palette.tab_bar.background } })
    table.insert(R, { Foreground = { Color = palette.ansi[5] } })
    table.insert(R, { Text = C.div.l })
    table.insert(R, { Background = { Color = palette.ansi[5] } })
    table.insert(R, { Foreground = { Color = palette.tab_bar.background } })
    table.insert(R, { Text = "󰃰 " })
    table.insert(R, { Background = { Color = palette.tab_bar.background } })
    table.insert(R, { Foreground = { Color = colours.inactive_tab.fg_color } })
    table.insert(R, { Text = time })
  end
  window:set_right_status(wezterm.format(R))
end)

return M
