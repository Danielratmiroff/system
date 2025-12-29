-- Add local LuaRocks path
package.path = package.path .. ";/home/daniel/.luarocks/share/lua/5.1/?.lua"
package.path = package.path .. ";/home/daniel/.luarocks/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";/home/daniel/.luarocks/lib/lua/5.1/?.so"

local wezterm = require("wezterm")
local markdown = require("markdown")
local act = wezterm.action

local config = wezterm.config_builder()
config:set_strict_mode(true)

config.font = wezterm.font("Hack")
config.font_size = 14
-- config.color_scheme = "Catppuccin Mocha (Gogh)"
--config.color_scheme = "ForestBlue"
config.color_scheme = "Tokyo Night Storm"
--config.color_scheme = "Github Dark (Gogh)"
--config.color_scheme = "Dracula"
config.window_background_opacity = 0.85

-- Set initial window dimensions
config.initial_rows = 40
config.initial_cols = 180

-- Directory-specific background colors
local dir_to_color = {
	["/home/daniel"] = { background = "#550000" },  
["/home/daniel/code/bavaria-matrix-react-sdk"] = { background = "#1a1a1a" },  
	["/home/daniel/code/bycs-messenger-android"] = { background = "#1a1a1a" }, 
	["/home/daniel/code/keycloakify-projects/keycloakify-starter"] = { background = "#771949" }, 
	["/home/daniel/code/keycloakify-projects/keycloak-theme-pupil"] = { background = "#025f73" } 
}

local TITLEBAR_COLOR = "#333333"
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	if not window then
		wezterm.log_error("Window is nil in gui-startup event")
		return
	end

	local screen = wezterm.gui.screens().main
	local padding = 150

	-- Calculate desired width and height with padding
	local desired_width = screen.width - (padding * 2)
	local desired_height = screen.height - (padding * 3)

	-- Calculate centered position
	local desired_position_x = padding
	local desired_position_y = padding

	-- Set the window size and position
	window:gui_window():set_inner_size(desired_width, desired_height)
	window:gui_window():set_position(desired_position_x, desired_position_y)
end)

config.native_macos_fullscreen_mode = true
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
	font = wezterm.font({
		family = "Hack",
		weight = "Bold",
	}),
	font_size = 13.0,
	active_titlebar_bg = TITLEBAR_COLOR,
	inactive_titlebar_bg = TITLEBAR_COLOR,
}

wezterm.on("update-status", function(window, pane)
	local cells = {}

	-- Detect shell user via user variable (set by fish/bash)
	local shell_user = pane:get_user_vars().SHELL_USER or ""
	local is_claude = (shell_user == "claude")

	-- Figure out the hostname of the pane on a best-effort basis
	local hostname = wezterm.hostname()
	local cwd_uri = pane:get_current_working_dir()
	if cwd_uri and cwd_uri.host then
		hostname = cwd_uri.host
	end

	-- Check if in claude's directory (for daniel)
	local in_claude_dir = false
	if cwd_uri then
		local path = cwd_uri.file_path or ""
		in_claude_dir = path:match("^/home/claude") ~= nil
	end

	-- Styling priority: logged-in-as-claude > in-claude-dir > dir-specific > default
	if is_claude then
		window:set_config_overrides({
			window_background_opacity = 0.85,
			colors = { background = "#1a1a2e" },
			window_frame = {
				active_titlebar_bg = "#2d2d44",
				inactive_titlebar_bg = "#2d2d44",
			}
		})
	elseif in_claude_dir then
		window:set_config_overrides({
			window_background_opacity = 0.85,
			colors = { background = "#1a1a2e" },
			window_frame = {
				active_titlebar_bg = "#2d2d44",
				inactive_titlebar_bg = "#2d2d44",
			}
		})
	elseif cwd_uri then
		local path = cwd_uri.file_path or ""
		local path_without_trailing_slash = path:gsub("/$", "")
		local overrides = dir_to_color[path_without_trailing_slash]
		if overrides then
			window:set_config_overrides({ window_background_opacity = 0.85, colors = overrides })
		else
			window:set_config_overrides({ window_background_opacity = 0.85 })
		end
	end

	-- Status bar: user indicator
	if is_claude then
		table.insert(cells, "◈ claude")
	elseif in_claude_dir then
		table.insert(cells, "[claude] " .. hostname)
	else
		table.insert(cells, " " .. hostname)
	end

	-- Format date/time in this style: "Wed Mar 3 08:14"
	local date = wezterm.strftime(" %a %b %-d %H:%M")
	table.insert(cells, date)

	-- Add an entry for each battery (typically 0 or 1)
	local batt_icons = { "", "", "", "", "" }
	for _, b in ipairs(wezterm.battery_info()) do
		local curr_batt_icon = batt_icons[math.ceil(b.state_of_charge * #batt_icons)]
		table.insert(cells, string.format("%s %.0f%%", curr_batt_icon, b.state_of_charge * 100))
	end

	config.hyperlink_rules = wezterm.default_hyperlink_rules()

	-- Color palette for each cell
	local text_fg = "#c0c0c0"
	local colors = { TITLEBAR_COLOR, "#3c1361", "#52307c", "#663a82", "#7c5295", "#b491c8" }

	local elements = {}
	while #cells > 0 and #colors > 1 do
		local text = table.remove(cells, 1)
		local prev_color = table.remove(colors, 1)
		local curr_color = colors[1]

		table.insert(elements, {
			Background = {
				Color = prev_color,
			},
		})
		table.insert(elements, {
			Foreground = {
				Color = curr_color,
			},
		})
		table.insert(elements, {
			Text = "",
		})
		table.insert(elements, {
			Background = {
				Color = curr_color,
			},
		})
		table.insert(elements, {
			Foreground = {
				Color = text_fg,
			},
		})
		table.insert(elements, {
			Text = " " .. text .. " ",
		})
	end
	window:set_right_status(wezterm.format(elements))
end)

config.keys = {
  {
		key = "q",
		mods = "ALT",
		action = act.QuitApplication,
  },
  {
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action{SendString="\x1b\r"}
	},
	{
		key = "1",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "2",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "j",
		mods = "ALT",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "ALT",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "p",
		mods = "SHIFT|CTRL",
		action = act.ActivateCommandPalette,
	},
	{
		key = "h",
		mods = "SHIFT|ALT",
		action = act.AdjustPaneSize({ "Left", 4 }),
	},
	{
		key = "x",
		mods = "SHIFT|CTRL",
		action = act.ShowLauncher,
	},
	{
		key = "j",
		mods = "SHIFT|ALT",
		action = act.AdjustPaneSize({ "Down", 4 }),
	},
	{
		key = "k",
		mods = "SHIFT|ALT",
		action = act.AdjustPaneSize({ "Up", 4 }),
	},
	{
		key = "k",
		mods = "SHIFT|ALT",
		action = act.AdjustPaneSize({ "Up", 4 }),
	},
	{
		key = "t",
		mods = "CTRL",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "q",
		mods = "CTRL",
		action = act({
			CloseCurrentPane = {
				confirm = true,
			},
		}),
	},
	{
		key = "s",
		mods = "ALT",
		action = act.SplitVertical,
	},
	{
		key = "\\",
		mods = "CTRL",
		action = act.SplitHorizontal,
	},
	{
		key = "PageUp",
		mods = "CTRL",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "PageDown",
		mods = "CTRL",
		action = act.ActivateTabRelative(1),
	}
  -- Floating panes (not implemented yet)
	-- bind "Alt w" { ToggleFloatingPanes; }
	-- bind "Alt e" { TogglePaneEmbedOrFloating; }
	-- bind "Alt b" { MovePaneBackwards; }
	-- Using defaults for tabs (CMD t, CMD 1-9)
	-- Using defaults for find (CMD f, CTRL-r to toggle case sensitivity & regex modes)
}

return config

