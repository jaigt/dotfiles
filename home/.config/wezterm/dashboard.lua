-- Dashboard layout — opened on demand with CMD+SHIFT+Enter, not at startup.
--
--   +----------------+---------------------------+
--   |  fastfetch     |                           |
--   +----------------+                           |
--   |  (bare shell)  |       (bare shell)        |
--   +----------------+                           |
--   |  cmatrix       |                           |
--   +----------------+---------------------------+
--
-- The constants below are absolute cell counts rather than ratios: only the
-- middle-left and right panes flex, which is what keeps fastfetch and cmatrix
-- looking right on a differently-sized display.

local wezterm = require("wezterm")

local M = {}

-- fastfetch renders at 89 wide; +1 so it never wraps. Tracks the logo and rail
-- widths in ~/.config/fastfetch/config.jsonc:
-- LEFT_COLS = logo.padding.left + logo.width + logo.padding.right + 52.
local LEFT_COLS = 90
local TOP_ROWS = 24 -- fastfetch is 27 lines, so its top 3 scroll off — intentional
local BOTTOM_ROWS = 7 -- cmatrix strip under the working pane

-- WezTerm hands its own environment to every pane it spawns. If WezTerm was
-- launched from inside a herdr pane, HERDR_ENV=1 leaks in and herdr refuses to
-- start ("nested herdr is disabled by default"), and the pane/tab/workspace ids
-- are stale. HERDR_SOCKET_PATH is kept so the client still finds the server.
local STRIP_ENV = { "HERDR_ENV", "HERDR_PANE_ID", "HERDR_TAB_ID", "HERDR_WORKSPACE_ID" }

-- argv for a login shell with the stale herdr vars stripped. With `cmdline`,
-- run it first and leave an interactive shell behind so the pane survives the
-- command exiting: `-l -c` sources ~/.zprofile, the exec'd `-i` sources
-- ~/.zshrc — each exactly once. Without it, just a plain login shell.
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

-- An integer `size` is a cell count for the NEW pane; a float would be a
-- fraction, applied to the pane's real pixel size at the instant the split runs
-- — during the post-maximize settle that is not the size get_size() reported.
--
-- So every split creates the pane being PINNED and the flexible panes are the
-- ones left over: split Left/Top rather than Right/Bottom, and `base` itself
-- ends up as the right pane.
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

	-- fastfetch prints once and can't reflow, so running it as the pane's argv
	-- lays its output out for the full-width pane and then hard-wraps it when
	-- these splits narrow the pane. Type it in instead, after the pane has
	-- settled at its final width.
	wezterm.time.call_after(0.3, function()
		fastfetch_pane:send_text("clear; fastfetch\n")
	end)

	base:activate()
end

-- The pinned columns and rows only fit a maximized window, so maximize first;
-- that resize is async, hence the delay before splitting a too-small window.
function M.spawn(gui_window)
	local _, base = gui_window:mux_window():spawn_tab({
		args = then_shell(),
	})
	gui_window:maximize()
	wezterm.time.call_after(0.4, function()
		build(base)
	end)
end

return M
