-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
config.font = wezterm.font({ family = "Liga SFMono Nerd Font" })
config.font_size = 13

config.window_frame = {
	font = wezterm.font({ family = "Liga SFMono Nerd Font" }),
	font_size = 14,
}

-- Set default program to Fish
config.default_prog = { "/opt/homebrew/bin/fish", "-l" }

-- Removes the title bar, leaving only the tab bar. Keeps
-- the ability to resize by dragging the window's edges.
-- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
-- you want to keep the window controls visible and integrate
-- them into the tab bar.
config.window_decorations = "RESIZE"

wezterm.on("update-status", function(window)
	-- Grab the utf8 character for the "powerline" left facing
	-- solid arrow.
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

	-- Grab the current window's configuration, and from it the
	-- palette (this is the combination of your chosen colour scheme
	-- including any overrides).
	local color_scheme = window:effective_config().resolved_palette
	local bg = color_scheme.background
	local fg = color_scheme.foreground

	window:set_right_status(wezterm.format({
		-- First, we draw the arrow...
		{ Background = { Color = "none" } },
		{ Foreground = { Color = bg } },
		{ Text = SOLID_LEFT_ARROW },
		-- Then we draw our text
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = " " .. wezterm.hostname() .. " " },
	}))
end)

-- For example, changing the initial geometry for new windows:
config.initial_cols = 180
config.initial_rows = 58

-- If you're using emacs you probably wanna choose a different leader here,
-- since we're gonna be making it a bit harder to CTRL + A for jumping to
-- the start of a line
config.leader = { key = "f", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- ... add these new entries to your config.keys table
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
}

-- Finally, return the configuration to wezterm:
return config
