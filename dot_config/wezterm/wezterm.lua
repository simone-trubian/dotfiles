-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"

local is_windows = wezterm.target_triple:find("windows") ~= nil

-- SF Mono comes from a Homebrew tap, so Windows uses JetBrains Mono. Picked
-- per OS rather than as a fallback, which warns on every start.
local font = wezterm.font(is_windows and "JetBrainsMono Nerd Font" or "Liga SFMono Nerd Font")

-- JetBrains Mono runs larger than SF Mono, so a point lower on Windows
local font_size = is_windows and 13 or 14

config.font = font
config.font_size = font_size

config.window_frame = {
	font = font,
	font_size = font_size,
}

-- Set default program to Fish, or PowerShell on Windows
if is_windows then
	config.default_prog = { "pwsh.exe", "-NoLogo" }
else
	config.default_prog = { "/opt/homebrew/bin/fish", "-l" }
end

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

	-- Show the active mode, like Vim's -- INSERT --: LEADER while the
	-- leader is waiting for a key, PANE while in pane mode.
	local mode = window:leader_is_active() and "leader" or window:active_key_table()
	local cells = {}
	local edge = "none"
	if mode then
		local badge = mode == "leader" and color_scheme.ansi[4] or color_scheme.ansi[5]
		table.insert(cells, { Background = { Color = "none" } })
		table.insert(cells, { Foreground = { Color = badge } })
		table.insert(cells, { Text = SOLID_LEFT_ARROW })
		table.insert(cells, { Background = { Color = badge } })
		table.insert(cells, { Foreground = { Color = bg } })
		table.insert(cells, { Text = " " .. mode:upper() .. " " })
		edge = badge
	end

	-- First, we draw the arrow...
	table.insert(cells, { Background = { Color = edge } })
	table.insert(cells, { Foreground = { Color = bg } })
	table.insert(cells, { Text = SOLID_LEFT_ARROW })
	-- Then we draw our text
	table.insert(cells, { Background = { Color = bg } })
	table.insert(cells, { Foreground = { Color = fg } })
	table.insert(cells, { Text = " " .. wezterm.hostname() .. " " })

	window:set_right_status(wezterm.format(cells))
end)

-- For example, changing the initial geometry for new windows:
config.initial_cols = 180
config.initial_rows = 58

local act = wezterm.action

-- Leader: Ctrl-;. Terminals can't send Ctrl-; to programs, so Neovim and
-- Fish never use it and nothing is lost by giving it to WezTerm.
config.leader = { key = ";", mods = "CTRL", timeout_milliseconds = 2000 }

-- Pane commands, Vim-style: available as Leader <key> and in pane mode.
local pane_keys = {
	{ key = "v", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) }, -- side by side, like :vsplit
	{ key = "s", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) }, -- stacked, like :split
	{ key = "h", action = act.ActivatePaneDirection("Left") },
	{ key = "j", action = act.ActivatePaneDirection("Down") },
	{ key = "k", action = act.ActivatePaneDirection("Up") },
	{ key = "l", action = act.ActivatePaneDirection("Right") },
	{ key = "x", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", action = act.TogglePaneZoomState },
}

config.keys = {}
local function leader_key(key, action)
	-- also match when Ctrl is still held from the leader
	for _, mods in ipairs({ "LEADER", "LEADER|CTRL" }) do
		table.insert(config.keys, { key = key, mods = mods, action = action })
	end
end
for _, k in ipairs(pane_keys) do
	leader_key(k.key, k.action)
end

-- Leader p: pane mode. Stays active, so h/j/k/l can be pressed repeatedly,
-- until Esc (or any key that isn't a pane command).
leader_key("p", act.ActivateKeyTable({ name = "pane", one_shot = false, until_unknown = true }))

local pane_mode = {}
for _, k in ipairs(pane_keys) do
	table.insert(pane_mode, k)
end
for key, dir in pairs({ H = "Left", J = "Down", K = "Up", L = "Right" }) do
	table.insert(pane_mode, { key = key, mods = "SHIFT", action = act.AdjustPaneSize({ dir, 5 }) })
end
for _, key in ipairs({ "Escape", "q", "Enter" }) do
	table.insert(pane_mode, { key = key, action = act.PopKeyTable })
end
config.key_tables = { pane = pane_mode }

-- Finally, return the configuration to wezterm:
return config
