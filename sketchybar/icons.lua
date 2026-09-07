-- nf-md range only. CaskaydiaCove is missing chunks of the other Nerd Font
-- ranges, and a missing glyph renders as an invisible blank, not a box — it
-- reads as a layout bug. Check the font really has one before adding it.

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
