-- Absolute cell counts, not ratios: only the middle-left and right panes flex,
-- which keeps fastfetch and cmatrix right on a differently-sized display.

local wezterm = require("wezterm")

local M = {}

-- Measured off the macOS ~/.config/fastfetch/config.jsonc — re-measure if that
-- file changes. Wrong for the Linux config, which is wider and taller. TODO.
local LEFT_COLS = 82
local TOP_ROWS = 18
local BOTTOM_ROWS = 7 -- cmatrix strip under the working pane

-- WezTerm hands its own env to every pane, so launching it from inside a herdr
-- pane leaks HERDR_ENV=1 (herdr then refuses to start) plus stale ids.
-- HERDR_SOCKET_PATH is kept so the client still finds the server.
local STRIP_ENV = { "HERDR_ENV", "HERDR_PANE_ID", "HERDR_TAB_ID", "HERDR_WORKSPACE_ID" }

-- `-l -c` sources ~/.zprofile and the exec'd `-i` sources ~/.zshrc, each
-- exactly once, leaving a shell behind so the pane survives the command.
local function then_shell(cmdline)
	local args = { "/usr/bin/env" }
	for _, var in ipairs(STRIP_ENV) do
		table.insert(args, "-u")
		table.insert(args, var)
	end
	table.insert(args, "/bin/zsh")
	table.insert(args, "-l")
	if cmdline then
		table.insert(args, "-c")
		table.insert(args, cmdline .. "; exec /bin/zsh -i")
	end
	return args
end

-- Integer `size` is a cell count for the NEW pane (a float would be a fraction
-- of the pane's pixel size mid-maximize-settle, which is not what get_size()
-- reported). So each split creates the pane being PINNED — Left/Top, never
-- Right/Bottom — and the leftovers flex.
local function build(base)
	local left = base:split({
		direction = "Left",
		size = LEFT_COLS,
		args = then_shell(),
	})

	local fastfetch_pane = left:split({
		direction = "Top",
		size = TOP_ROWS,
		args = then_shell(),
	})

	left:split({
		direction = "Bottom",
		size = BOTTOM_ROWS,
		args = then_shell("cmatrix"),
	})

	-- fastfetch can't reflow, so as pane argv it lays out at full width and then
	-- hard-wraps when the splits narrow the pane. Type it in once settled.
	wezterm.time.call_after(0.3, function()
		fastfetch_pane:send_text("clear; fastfetch\n")
	end)

	base:activate()
end

-- Maximize first — the pinned sizes only fit a maximized window — and the
-- resize is async, hence the delay.
function M.spawn(gui_window)
	local _, base = gui_window:mux_window():spawn_tab({
		args = then_shell("nvim"),
	})
	gui_window:maximize()
	wezterm.time.call_after(0.4, function()
		build(base)
	end)
end

return M
