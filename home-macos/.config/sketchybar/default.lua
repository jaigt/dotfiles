local colors = require("colors")
local settings = require("settings")

sbar.default({
  -- A drawing=false item inherits this and then never updates again, so it can
  -- never turn itself back on. Any item that hides itself needs updates="on".
  updates = "when_shown",

  icon = {
    font = { family = settings.font, style = "Bold", size = 14.0 },
    color = colors.fg,
    padding_left = 10,
    padding_right = 5,
  },

  label = {
    font = { family = settings.font, style = "SemiBold", size = 13.0 },
    color = colors.fg,
    padding_left = 0,
    padding_right = 10,
  },

  padding_left = 3,
  padding_right = 3,

  -- Only the brackets in items/init.lua draw a pill.
  background = { drawing = false },

  popup = {
    background = {
      color = colors.popup_bg,
      corner_radius = 10,
      border_width = 1,
      border_color = colors.popup_border,
      shadow = { drawing = true },
    },
    blur_radius = 30,
    y_offset = 6,
    horizontal = false,
  },
})
