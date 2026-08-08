local colors = require("colors")
local settings = require("settings")

sbar.bar({
  height = settings.bar_height,
  notch_width = settings.notch_width,
  position = "top",
  sticky = true,

  -- topmost, not notch_display_height, is what decides where the bar sits:
  --   false -> bar at y=32, below the notch    true -> y=0, menu bar strip
  -- So "below" needs it off and "replace" needs it on. Must be set here, not in
  -- init.lua: a later sbar.bar() call inside the batched begin_config /
  -- end_config block does not take effect for this property.
  topmost = (settings.mode == "replace"),
  padding_left = settings.edge_margin,
  padding_right = settings.edge_margin,
  color = colors.bar_color,
  blur_radius = 0,
  shadow = false,
  font_smoothing = true,
  y_offset = 0,
  margin = 0,
  corner_radius = 0,
  display = "main",

  -- notch_display_height is applied at the end of init.lua: it has no effect
  -- when set here, because the bar has no geometry yet for it to act on.
})
