-- All from the nf-md (Material Design, U+F0xxx) range of CaskaydiaCove. The
-- nf-fa and nf-oct cpu/memory glyphs, the Devicons branch glyph, the
-- FontAwesome clock and U+F8FF (the Apple logo) are *absent* from this font,
-- and a missing glyph renders as an invisible blank rather than a box — so it
-- looks like a layout bug, not a font problem. Before adding one, check the
-- font really has it (fonttools against
-- ~/Library/Fonts/CaskaydiaCoveNerdFont-Regular.ttf).

return {
  logo = "󰀵",

  cpu    = "󰻠",
  memory = "󰍛",
  disk   = "󰋊",
  uptime = "󰅐",

  battery = {
    _100     = "󰁹",
    _75      = "󰂀",
    _50      = "󰁾",
    _25      = "󰁻",
    _0       = "󰂎",
    charging = "󰂄",
  },

  volume = {
    _100 = "󰕾",
    _66  = "󰖀",
    _33  = "󰕿",
    _0   = "󰝟",
  },

  wifi     = "󰖩",
  wifi_off = "󰖪",

  media = {
    play  = "󰐊",
    pause = "󰏤",
    note  = "󰎈",
  },

  git    = "󰘬",
  claude = "󰛄",
  clock  = "󰥔",
}
