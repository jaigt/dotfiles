-- Rosé Pine "graphite". Sketchybar wants 0xAARRGGBB, hence the alpha byte on
-- every colour. Surplus hue slots are aliases, not new colours.

local M = {
  -- Background tiers, graphite ------------------------------------------------
  bg    = 0xff1e1e1e, -- base
  bg_m1 = 0xff1a1a1a, -- one step down: _nc
  bg_p1 = 0xff262626, -- one step up: surface
  bg_p2 = 0xff2f2f2f, -- two steps up: overlay -- borders, dividers
  bg_p3 = 0xff5b5b5b, -- three: highlight high, the lightest structural grey

  -- Text tiers ---------------------------------------------------------------
  fg     = 0xffe0def4, -- text
  fg_dim = 0xff908caa, -- subtle: secondary labels
  gray   = 0xff6e6a86, -- muted: disabled text, dividers

  -- Hues ---------------------------------------------------------------------
  red    = 0xffeb6f92, -- love
  orange = 0xffebbcba, -- rose: the only warm tone between gold and love
  yellow = 0xfff6c177, -- gold
  green  = 0xff31748f, -- pine: the palette has no green
  aqua   = 0xff9ccfd8, -- foam (alias of blue)
  blue   = 0xff9ccfd8, -- foam
  violet = 0xffc4a7e7, -- iris
  pink   = 0xffeb6f92, -- love (alias of red)

  transparent = 0x00000000,
}

M.bar_color    = M.transparent
M.pill_bg      = 0xd9262626 -- ~85% bg_p1
M.pill_border  = 0x805b5b5b -- ~50% bg_p3
M.popup_bg     = 0xf2262626
M.popup_border = M.bg_p2

M.accent = M.blue
M.good   = M.green
M.warn   = M.yellow
M.urgent = M.red

return M
