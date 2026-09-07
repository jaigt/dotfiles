-- Retro tab bar, not the fancy one: the fancy bar forces an X on every tab and
-- draws its own chrome around what format-tab-title returns. The retro bar
-- renders that return value and nothing else, and ignores window_frame.
--
-- WezTerm has no "centre the tabs" option, so centring means measuring the
-- blocks and emitting that many spaces as left_status each tick. Hence
-- `segments`: format-tab-title must draw exactly what the status handler
-- measured, or the two drift apart.
--
-- The leading number is the tab's own CMD+<n>, a WezTerm default.

local wezterm = require("wezterm")
local colors = require("colors")

local M = {}

-- ANSI slots, not literal hexes, so these follow colors.lua's active palette.
local BAR_BG = "rgba(0,0,0,0)" -- the bar strip shows the window backdrop; only the blocks paint
local BLOCK_BG = colors.ansi[1] -- one step off the base, so the block reads as a block
local BLOCK_FG = colors.tab_bar.inactive_tab.fg_color -- muted: an inactive title
local BLOCK_FG_BRIGHT = colors.tab_bar.inactive_tab_hover.fg_color -- subtle: the index, and a hovered title
local ACTIVE_BG = colors.ansi[5]
local ACTIVE_FG = colors.background -- the active block's text sits on the accent

local MAX_TITLE = 20
local GAP = "  "

-- argv[0], not the exe path: Claude Code lives in a versioned directory, so its
-- basename reads as a version number. get_foreground_process_info returns nil
-- on remote domains, and the name is "" not nil when unreadable — hence the
-- fallbacks.
local function title_of(pane)
	local info = pane:get_foreground_process_info()
	local name = info and (info.argv and info.argv[1] or info.executable)
	name = name or pane:get_foreground_process_name()
	if name == nil or name == "" then
		return pane:get_title()
	end
	return name:match("([^/]+)$") or name
end

local function segments(index, title)
	if wezterm.column_width(title) > MAX_TITLE then
		title = wezterm.truncate_right(title, MAX_TITLE - 1) .. "…"
	end
	return " " .. index .. " ", title .. " "
end

wezterm.on("format-tab-title", function(tab, tabs, _, _, hover)
	-- PaneInformation carries only the exe path; the mux pane exposes argv.
	local pane = wezterm.mux.get_pane(tab.active_pane.pane_id)
	local index, body = segments(tab.tab_index + 1, pane and title_of(pane) or tab.active_pane.title)

	local bg, fg, index_fg
	if tab.is_active then
		bg, fg, index_fg = ACTIVE_BG, ACTIVE_FG, ACTIVE_FG
	else
		bg = BLOCK_BG
		fg = hover and BLOCK_FG_BRIGHT or BLOCK_FG
		index_fg = BLOCK_FG_BRIGHT
	end

	return {
		{ Background = { Color = bg } },
		{ Foreground = { Color = index_fg } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = index },
		{ Foreground = { Color = fg } },
		{ Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
		{ Text = body },
		{ Background = { Color = BAR_BG } },
		{ Attribute = { Intensity = "Normal" } },
		{ Text = tab.tab_index == #tabs - 1 and "" or GAP },
	}
end)

wezterm.on("update-status", function(window, _)
	local tabs = window:mux_window():tabs_with_info()

	local width = (#tabs - 1) * wezterm.column_width(GAP)
	for _, t in ipairs(tabs) do
		local index, body = segments(t.index + 1, title_of(t.tab:active_pane()))
		width = width + wezterm.column_width(index) + wezterm.column_width(body)
	end

	local cols = window:active_tab():get_size().cols
	local pad = math.floor((cols - width) / 2)
	window:set_left_status(pad > 0 and string.rep(" ", pad) or "")
end)

function M.apply(config)
	config.use_fancy_tab_bar = false
	config.hide_tab_bar_if_only_one_tab = true
	config.tab_bar_at_bottom = true
	-- Load-bearing: a block runs wider than WezTerm's default cap, which would
	-- truncate it out from under the centring maths.
	config.tab_max_width = 32
	-- The "+" sits at the right edge of the group and pulls it off centre.
	config.show_new_tab_button_in_tab_bar = false
	-- The palette's bar colour fills the centring pad and the run past the last
	-- tab; override it here so the whole strip stays transparent.
	config.colors.tab_bar.background = BAR_BG
end

return M
