-- Tab bar: centred solid blocks along the bottom — ` 1 zsh   2 nvim `
--
-- The retro tab bar, not the fancy one. The fancy bar hard-codes an X on every
-- tab — there's no setting that removes it — and draws its own chrome around
-- whatever format-tab-title returns. The retro bar renders that return value
-- and nothing else, which is the only way to get bare colour blocks. It also
-- ignores config.window_frame, which is why none is set.
--
-- WezTerm has no "centre the tabs" option. The retro bar lays out
-- left_status → tabs → right_status, so centring means measuring the blocks and
-- emitting that many spaces as left_status on each update-status tick. That is
-- why `segments` exists: format-tab-title draws exactly the string the status
-- handler measured, and the two must not drift apart.
--
-- The leading number is the tab's own CMD+<n> shortcut — a WezTerm default
-- (SUPER+1..8 -> tab 1..8, SUPER+9 -> last tab), so nothing is bound here.

local wezterm = require("wezterm")
local colors = require("colors")

local M = {}

-- Taken from the ANSI slots rather than literal hexes so these follow whichever
-- palette colors.lua is set to.
local BAR_BG = colors.tab_bar.background
local BLOCK_BG = colors.ansi[1] -- one step off the base, so the block reads as a block
local BLOCK_FG = colors.tab_bar.inactive_tab.fg_color -- muted: an inactive title
local BLOCK_FG_BRIGHT = colors.tab_bar.inactive_tab_hover.fg_color -- subtle: the index, and a hovered title
local ACTIVE_BG = colors.ansi[5]
local ACTIVE_FG = colors.background -- the active block's text sits on the accent

local MAX_TITLE = 20
local GAP = "  "

-- argv[0], not the executable path: Claude Code installs its binary under
-- .../claude/versions/2.1.226, so the exe basename reads as a version number.
-- argv[0] is what you actually typed. get_foreground_process_info returns nil
-- for panes WezTerm can't inspect (remote domains), hence the two fallbacks —
-- and the process name is "" rather than nil when unreadable.
local function title_of(pane)
	local info = pane:get_foreground_process_info()
	local name = info and (info.argv and info.argv[1] or info.executable)
	name = name or pane:get_foreground_process_name()
	if name == nil or name == "" then
		return pane:get_title()
	end
	return name:match("([^/]+)$") or name
end

-- The block, split where its two colours change: ` 1 ` and `nvim `.
local function segments(index, title)
	if wezterm.column_width(title) > MAX_TITLE then
		title = wezterm.truncate_right(title, MAX_TITLE - 1) .. "…"
	end
	return " " .. index .. " ", title .. " "
end

wezterm.on("format-tab-title", function(tab, tabs, _, _, hover)
	-- format-tab-title is handed PaneInformation, which carries only the exe
	-- path; the mux pane is what exposes argv.
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
	-- Load-bearing, not a leftover: a block runs to MAX_TITLE + 5 columns, and
	-- the default cap of 16 would truncate it out from under the centring maths.
	config.tab_max_width = 32
	-- The "+" would sit at the right edge of the block group and pull it off
	-- centre; CMD+T is the way in.
	config.show_new_tab_button_in_tab_bar = false
end

return M
