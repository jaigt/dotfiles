-- Noctalia template -> ~/.config/wezterm/colors-noctalia.lua
-- Emits a Lua module in the same shape wezterm/colors.lua returns, so
-- appearance.lua (config.colors = ...) and tabs.lua (ansi[5]) work unchanged.
-- Tab bar mirrors the flat Kanagawa style, not Noctalia's primary-pill look.
return {
  foreground = '{{colors.terminal_foreground.default.hex}}',
  background = '{{colors.terminal_background.default.hex}}',

  cursor_bg = '{{colors.terminal_cursor.default.hex}}',
  cursor_fg = '{{colors.terminal_cursor_text.default.hex}}',
  cursor_border = '{{colors.terminal_cursor.default.hex}}',

  selection_fg = '{{colors.terminal_selection_fg.default.hex}}',
  selection_bg = '{{colors.terminal_selection_bg.default.hex}}',

  scrollbar_thumb = '{{colors.terminal_selection_bg.default.hex}}',
  split = '{{colors.terminal_selection_bg.default.hex}}',

  ansi = {
    '{{colors.terminal_normal_black.default.hex}}',
    '{{colors.terminal_normal_red.default.hex}}',
    '{{colors.terminal_normal_green.default.hex}}',
    '{{colors.terminal_normal_yellow.default.hex}}',
    '{{colors.terminal_normal_blue.default.hex}}',
    '{{colors.terminal_normal_magenta.default.hex}}',
    '{{colors.terminal_normal_cyan.default.hex}}',
    '{{colors.terminal_normal_white.default.hex}}',
  },
  brights = {
    '{{colors.terminal_bright_black.default.hex}}',
    '{{colors.terminal_bright_red.default.hex}}',
    '{{colors.terminal_bright_green.default.hex}}',
    '{{colors.terminal_bright_yellow.default.hex}}',
    '{{colors.terminal_bright_blue.default.hex}}',
    '{{colors.terminal_bright_magenta.default.hex}}',
    '{{colors.terminal_bright_cyan.default.hex}}',
    '{{colors.terminal_bright_white.default.hex}}',
  },

  tab_bar = {
    background = '{{colors.terminal_background.default.hex}}',
    active_tab = {
      bg_color = '{{colors.terminal_background.default.hex}}',
      fg_color = '{{colors.terminal_foreground.default.hex}}',
    },
    inactive_tab = {
      bg_color = '{{colors.terminal_background.default.hex}}',
      fg_color = '{{colors.terminal_bright_black.default.hex}}',
    },
    inactive_tab_hover = {
      bg_color = '{{colors.terminal_background.default.hex}}',
      fg_color = '{{colors.on_surface_variant.default.hex}}',
    },
    new_tab = {
      bg_color = '{{colors.terminal_background.default.hex}}',
      fg_color = '{{colors.terminal_bright_black.default.hex}}',
    },
    new_tab_hover = {
      bg_color = '{{colors.terminal_background.default.hex}}',
      fg_color = '{{colors.terminal_foreground.default.hex}}',
    },
  },
}
