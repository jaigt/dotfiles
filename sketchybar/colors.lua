-- Sketchybar wants 0xAARRGGBB, hence the alpha byte on every colour. Surplus
-- hue slots are aliases, not new colours. ACTIVE is rewritten by `theme`.

local ACTIVE = "rose-pine" -- 'rose-pine' | 'gruvbox-material'

local palettes = {}

-- Rosé Pine "graphite"
palettes["rose-pine"] = {
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

  accent = 0xff9ccfd8, -- foam
}

-- Gruvbox Material, dark medium (sainnhe/gruvbox-material)
palettes["gruvbox-material"] = {
  bg    = 0xff282828, -- bg0
  bg_m1 = 0xff1b1b1b, -- bg_dim
  bg_p1 = 0xff32302f, -- bg1
  bg_p2 = 0xff45403d, -- bg3
  bg_p3 = 0xff5a524c, -- bg5

  fg     = 0xffc1c1c1, -- fg0
  fg_dim = 0xff9b9b9b, -- grey2
  gray   = 0xff858585, -- grey1

  red    = 0xffea6962,
  orange = 0xffe78a4e,
  yellow = 0xffd8a657,
  green  = 0xffa9b665,
  aqua   = 0xff89b482,
  blue   = 0xff7daea3,
  violet = 0xffd3869b, -- purple
  pink   = 0xffd3869b, -- purple (alias)

  accent = 0xff89b482, -- aqua: the foam-equivalent
}

local M = palettes[ACTIVE]
M.transparent = 0x00000000

local function rgb(c) return c % 0x1000000 end

M.bar_color    = M.transparent
M.pill_bg      = 0xd9000000 + rgb(M.bg_p1) -- ~85% bg_p1
M.pill_border  = 0x80000000 + rgb(M.bg_p3) -- ~50% bg_p3
M.popup_bg     = 0xf2000000 + rgb(M.bg_p1)
M.popup_border = M.bg_p2

M.good   = M.green
M.warn   = M.yellow
M.urgent = M.red

return M
