-- Keybindings. CMD+1..8 (jump to tab) and CMD+9 (last tab) are WezTerm
-- defaults, so they aren't listed here.

local wezterm = require 'wezterm'
local act = wezterm.action
local dashboard = require 'dashboard'

local M = {}

function M.apply(config)
  config.keys = {
    -- Panes
    { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'w', mods = 'CMD', action = act.CloseCurrentPane { confirm = false } },
    -- WezTerm's close-tab bindings confirm first; these don't.
    { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = false } },
    { key = 'w', mods = 'CMD|SHIFT', action = act.CloseCurrentTab { confirm = false } },
    { key = 'Enter', mods = 'CMD', action = act.TogglePaneZoomState },
    { key = 'LeftArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Left' },
    { key = 'RightArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Right' },
    { key = 'UpArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Up' },
    { key = 'DownArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Down' },

    -- Pane resize
    { key = 'LeftArrow', mods = 'CTRL|CMD', action = act.AdjustPaneSize { 'Left', 3 } },
    { key = 'RightArrow', mods = 'CTRL|CMD', action = act.AdjustPaneSize { 'Right', 3 } },
    { key = 'UpArrow', mods = 'CTRL|CMD', action = act.AdjustPaneSize { 'Up', 3 } },
    { key = 'DownArrow', mods = 'CTRL|CMD', action = act.AdjustPaneSize { 'Down', 3 } },

    -- Tabs
    { key = 't', mods = 'CMD', action = act.SpawnTab 'CurrentPaneDomain' },
    -- Dashboard: fastfetch / cmatrix / shells in a new maximized tab.
    {
      key = 'Enter',
      mods = 'CMD|SHIFT',
      action = wezterm.action_callback(function(window, _)
        dashboard.spawn(window)
      end),
    },
    { key = '[', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = ']', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(1) },

    -- Cmd+V that also handles images.
    --
    -- PasteFrom(Clipboard) reads the clipboard as TEXT; an image has no text
    -- flavor so it's dropped before the program sees it. Claude Code pastes
    -- images by receiving a raw Ctrl+V and reading the clipboard itself, which
    -- works only because WezTerm leaves Ctrl+V unbound.
    -- So: text -> normal paste, no text -> forward Ctrl+V to the program.
    -- The text probe is per-OS: pbpaste on macOS, wl-paste on Wayland.
    {
      key = 'v',
      mods = 'CMD',
      action = wezterm.action_callback(function(window, pane)
        local has_text
        if wezterm.target_triple:find 'darwin' then
          local ok, text = wezterm.run_child_process { '/usr/bin/pbpaste' }
          has_text = ok and text ~= nil and text ~= ''
        else
          has_text = wezterm.run_child_process {
            'sh', '-c', 'wl-paste --list-types 2>/dev/null | grep -q ^text/',
          }
        end
        if has_text then
          window:perform_action(act.PasteFrom 'Clipboard', pane)
        else
          window:perform_action(act.SendKey { key = 'v', mods = 'CTRL' }, pane)
        end
      end),
    },

    -- Buffer
    { key = 'k', mods = 'CMD', action = act.ClearScrollback 'ScrollbackAndViewport' },
    { key = 'f', mods = 'CMD', action = act.Search { CaseInSensitiveString = '' } },
    { key = 'p', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },

    -- Word-wise motion
    { key = 'LeftArrow', mods = 'OPT', action = act.SendString '\x1bb' },
    { key = 'RightArrow', mods = 'OPT', action = act.SendString '\x1bf' },
  }
end

return M
