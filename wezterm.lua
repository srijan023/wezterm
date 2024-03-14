local wezterm = require("wezterm")
local config = wezterm.config_builder()

----------------------------------- FONTS CONFIG -----------------------------------------------

-- after chaning the current font size, wezterm jumps around and changes its window size, disable that
config.adjust_window_size_when_changing_font_size = false

-- setting up font for normal usecase
config.font = wezterm.font({ family = "Hack Nerd Font", weight = "Regular" })

config.font_rules = {
	-- only bold
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font_with_fallback({
			family = "Hack Nerd Font",
		}),
	},

	-- bold and italic
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font_with_fallback({
			family = "JetBrainsMono Nerd Font",
			italic = true,
		}),
	},

	-- normal intensity and italic
	{
		intensity = "Half",
		italic = true,
		font = wezterm.font_with_fallback({
			family = "JetBrainsMono Nerd Font",
			italic = true,
		}),
	},
}

---------------------------------- WEZTERM OPTIONS -----------------------------------

config.audible_bell = "Disabled" -- no irritating sound notifications
config.disable_default_key_bindings = true -- disable the default system keybindings
config.automatically_reload_config = true -- reload config when we save teh config file
config.scrollback_lines = 10000 -- cmd history length
config.status_update_interval = 1000 -- update the status bar of terminal in every x/1000 seconds
config.default_prog = { "pwsh.exe" } -- run windows poweshell as default shell 
config.window_close_confirmation = "NeverPrompt" -- never ask to confirm the closing of tab or terminal
config.force_reverse_video_cursor = true -- cursor take the color around it
config.use_dead_keys = false

------------------------------ VISIBLE CHANGES --------------------------------------

-- default size on new window
config.initial_rows = 52
config.initial_cols = 188

-- setting up the window padding
config.window_padding = {
  left = 2,
  right = 2,
  top = 10,
  bottom = 0,
}

-- color scheme
-- config.color_scheme = "Catppuccin Macchiato (Gogh)"
config.color_scheme = "Gruvbox Material (Gogh)"
config.color_scheme = "Tokyo Night"

-- visibility
config.window_background_opacity = 0.97
config.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.5,
}

-- tab bar customization
config.window_decorations = "RESIZE" -- do not show default window title bar allow tab bar to resize
config.enable_tab_bar = true -- show the tab bar
config.use_fancy_tab_bar = false -- do not use the fancy browser app like tab bar
config.show_tabs_in_tab_bar = true -- show tab view on tab bar
config.show_new_tab_button_in_tab_bar = false -- do not show the add tab button

-- animation fps
config.animation_fps = 60

-- getting out the base name 
-- given /foo/bar or C:\\foo\\bar return 'bar'
function Basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

-- this is used only because using window object requires us to use callback
-- wezterm.on("update-status", function(window, _)
--   -- set the position of left top window corner
-- 	window:set_position(15, 15)
-- end)

-- setting up the right status view of terminal
wezterm.on("update-right-status", function(window, pane)
	-- if nothing interesting is going on display the current workspace name
	local stat_right = window:active_workspace()

	-- if the keytable is active
	if window:active_key_table() then
		stat_right = window:active_key_table()
	end

	-- if the leader is active
	if window:leader_is_active() then
		stat_right = "LEADER"
	end

  -- get the base name of foregound process
	local cmd = pane:get_foreground_process_name()
	cmd = Basename(cmd)

  -- sample format for date Sun Mar-10 09:44 AM
	local time = wezterm.strftime("%a %b-%d %I:%M %p")

	window:set_right_status(wezterm.format({
		{ Text = wezterm.nerdfonts.oct_table .. "  " .. stat_right },
		{ Text = " | " },
		{ Foreground = { Color = "#FFB86C" } },
		{ Text = wezterm.nerdfonts.md_application_brackets .. "  " .. cmd },
		"ResetAttributes",
		{ Text = " | " },
		{ Text = wezterm.nerdfonts.cod_calendar .. "  " .. time },
		{ Text = " |" },
	}))
end)

-- setting default tab title
-- [Tab #<tab-index + 1>]
function tab_title(tab)
	local title = tab.tab_title
	-- if the title is explicitly set get that tile else set Tab #num
	if title and #title > 0 then
		return title
	end

	return "Tab #" .. tab.tab_index + 1
end

-- setting up the look of tab in the tab-bar
wezterm.on("format-tab-title", function(tab, _, _, _, _, _)
	local title = tab_title(tab)
	local solid_left_arrow = ""
	local solid_right_arrow = ""

	-- local borderView = "#333333"
	local borderView = "#191b28"
	local hideColor = "#191b28"
	local foregroundColor = "#FFB"
	local blackColor = "#090909"

	if tab.is_active then
    -- if the tab is active set this color
		borderView = "#de5d68"
	end

	return {
		{ Background = { Color = hideColor } },
		{ Foreground = { Color = borderView } },
		{ Text = "(" },
		{ Foreground = { Color = foregroundColor } },
		{ Text = solid_left_arrow },
		{ Background = { Color = foregroundColor } },
		{ Foreground = { Color = blackColor } },
		{ Text = title },
		"ResetAttributes",
		{ Foreground = { Color = foregroundColor } },
		{ Background = { Color = hideColor } },
		{ Text = solid_right_arrow },
		{ Foreground = { Color = borderView } },
		{ Text = ")" },
		{ Background = { Color = hideColor } },
	}
end)

---------------------------- KEYBINDINGS -------------------------------
local act = wezterm.action

config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- Send C-a when pressing C-a twice
	{ key = "q", mods = "LEADER", action = act.SendKey({ key = "q", mods = "CTRL" }) },

	-- reloading the config
	{ key = "R", mods = "LEADER", action = act.ReloadConfiguration },
	--------------------------- Pane keybindings ---------------------------------------------

	-- splits
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- movements
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- controls
	{ key = "d", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

	-- manipulating the pane size
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

	--------------------- Tab keybindigs -----------------------------
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "t", mods = "LEADER", action = act.ShowTabNavigator },

	{ key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },

	-- renaming the current tab
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	--------------------- Workspace keybindings --------------------------------
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

	-- zoom state toggle
	-- A zoomed pane takes up all the available sapce in the tab hiding all the other panes
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

}

------------------------- USING TAB TO NAVIGATE TABS ------------------
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

------------------------------ CUSTOM TABLES ---------------------------

config.key_tables = {
	--============= Table for resizing the pane ====================--
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},

	--================= Table for moving tab around ==========================--
	move_tab = {
		{ key = "h", action = act.MoveTabRelative(-1) }, -- To the left
		{ key = "l", action = act.MoveTabRelative(1) }, -- To the right
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

return config
