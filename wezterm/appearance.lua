local wezterm = require 'wezterm'
local colors = require 'colors'

local M = {}

function M.apply(config)
  config.font = wezterm.font_with_fallback {
    'CaskaydiaCove Nerd Font Mono',
    'Symbols Nerd Font Mono',
    'Apple Color Emoji',
  }
  config.font_size = 13.0
  config.line_height = 1.0
  config.adjust_window_size_when_changing_font_size = false

  -- WezTerm blends alpha linearly through FreeType, so strokes come out thinner
  -- than a CoreText terminal's. No blending-space switch, so compensate here.
  config.foreground_text_hsb = { brightness = 1.15, saturation = 1.0, hue = 1.0 }

  -- If still thin: these thicken the strokes. HorizontalLcd is subpixel AA —
  -- sharper, but can fringe on a Retina panel.
  -- config.freetype_load_target = 'Light'
  -- config.freetype_render_target = 'HorizontalLcd'

  -- A cap, not a target: WezTerm only repaints on change. Too low is a ceiling.
  config.max_fps = 165

  config.colors = colors

  config.window_background_opacity = 0.88
  config.macos_window_background_blur = 36
  -- Wayland: 'RESIZE' summons glitchy fallback decorations.
  if wezterm.target_triple:find('darwin') then
    config.window_decorations = 'RESIZE'
  else
    config.window_decorations = 'NONE'
  end
  config.window_close_confirmation = 'NeverPrompt'

  -- Named here = closes silently. WezTerm's default covers bare shells only.
  config.skip_close_confirmation_for_processes_named = {
    'bash', 'sh', 'zsh', 'fish', 'nu', 'tmux',
    'claude', 'node', 'bun', 'deno', 'python3', 'python',
    'nvim', 'vim', 'less', 'man', 'ssh', 'git', 'fastfetch',
  }
  config.window_padding = { left = 12, right = 12, top = 10, bottom = 8 }
  config.initial_cols = 120
  config.initial_rows = 34

  config.default_cursor_style = 'BlinkingBar'
  config.cursor_blink_rate = 600
  config.cursor_blink_ease_in = 'Constant'
  config.cursor_blink_ease_out = 'Constant'

  config.scrollback_lines = 10000
  config.enable_scroll_bar = false
  config.audible_bell = 'Disabled'
  config.check_for_updates = true
  config.default_prog = { '/bin/zsh', '-l' }

  -- No OSC 52 setting on purpose: WezTerm already allows writes, blocks reads.

  -- No per-tab command hook exists: put it in ~/.zshrc behind $WEZTERM_PANE.
end

return M
