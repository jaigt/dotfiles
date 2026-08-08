-- Fonts, text rendering, window chrome and cursor.

local wezterm = require 'wezterm'
local colors = require 'colors'

local M = {}

function M.apply(config)
  ------------------------------------------------------------------------------
  -- Fonts
  ------------------------------------------------------------------------------
  config.font = wezterm.font_with_fallback {
    'CaskaydiaCove Nerd Font Mono',
    'Symbols Nerd Font Mono',
    'Apple Color Emoji',
  }
  config.font_size = 13.0
  config.line_height = 1.0
  config.adjust_window_size_when_changing_font_size = false

  -- Text weight. WezTerm rasterises through FreeType and blends alpha linearly,
  -- so strokes come out thinner than a CoreText terminal's at the same size.
  -- There's no blending-space switch, so compensate here. 1.0 is stock.
  config.foreground_text_hsb = { brightness = 1.15, saturation = 1.0, hue = 1.0 }

  -- If it still reads thin, these thicken the strokes themselves. HorizontalLcd
  -- is subpixel AA — sharper, but it can throw colour fringes on a Retina panel.
  -- config.freetype_load_target = 'Light'
  -- config.freetype_render_target = 'HorizontalLcd'

  ------------------------------------------------------------------------------
  -- Rendering
  ------------------------------------------------------------------------------
  -- Global cap, not a target — WezTerm only repaints when content changes. Set
  -- to the external monitor's rate; too low is a ceiling it can never exceed.
  config.max_fps = 165

  ------------------------------------------------------------------------------
  -- Colors
  ------------------------------------------------------------------------------
  config.colors = colors

  ------------------------------------------------------------------------------
  -- Window
  ------------------------------------------------------------------------------
  config.window_background_opacity = 0.88
  config.macos_window_background_blur = 36
  -- Wayland: 'RESIZE' still summons glitchy fallback decorations; Hyprland
  -- owns the window chrome anyway.
  if wezterm.target_triple:find('darwin') then
    config.window_decorations = 'RESIZE'
  else
    config.window_decorations = 'NONE'
  end
  config.window_close_confirmation = 'NeverPrompt'

  -- If the pane's foreground process is named here it closes silently. The
  -- default list is bare shells only, so `claude`, vim, ssh etc. all prompt.
  config.skip_close_confirmation_for_processes_named = {
    'bash', 'sh', 'zsh', 'fish', 'nu', 'tmux',
    'claude', 'node', 'bun', 'deno', 'python3', 'python',
    'nvim', 'vim', 'less', 'man', 'ssh', 'git', 'fastfetch',
  }
  config.window_padding = { left = 12, right = 12, top = 10, bottom = 8 }
  config.initial_cols = 120
  config.initial_rows = 34

  ------------------------------------------------------------------------------
  -- Cursor
  ------------------------------------------------------------------------------
  config.default_cursor_style = 'BlinkingBar'
  config.cursor_blink_rate = 600
  config.cursor_blink_ease_in = 'Constant'
  config.cursor_blink_ease_out = 'Constant'

  ------------------------------------------------------------------------------
  -- Terminal behaviour
  ------------------------------------------------------------------------------
  config.scrollback_lines = 10000
  config.enable_scroll_bar = false
  config.audible_bell = 'Disabled'
  config.check_for_updates = true
  config.default_prog = { '/bin/zsh', '-l' }

  -- No OSC 52 setting here on purpose: WezTerm already allows clipboard writes
  -- and blocks reads by default, which is the wanted behaviour.

  -- WezTerm has no per-tab command hook. To run something in every new tab, put
  -- it in ~/.zshrc behind `[[ -n "$WEZTERM_PANE" ]]`.
end

return M
