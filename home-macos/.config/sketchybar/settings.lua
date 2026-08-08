-- Shared geometry and typography.

return {
  font = "CaskaydiaCove NF",
  -- Fixed-width variant. Anything laid out in columns — the calendar grid, the
  -- IP rows — has to use this or it won't line up.
  mono = "CaskaydiaCove NFM",

  bar_height  = 36,
  pill_height = 26,
  notch_width = 210,

  -- How far below the top edge the bar should sit in "below" mode — far enough
  -- to clear the notch. This is a target, not an offset: init.lua measures where
  -- the bar actually lands and corrects the difference.
  top_inset = 32,

  -- How far the outer pills sit from the screen edges — the number the rest of
  -- the desktop grid lines up with. See docs/sketchybar.md.
  edge_margin = 64,

  -- Where the bar sits relative to the macOS menu bar.
  --   "below"    y=32, under the notch, but *behind* windows, so most
  --              maximised windows hide it. Centred items are possible.
  --   "replace"  y=0, in the menu bar strip, above all windows — but it covers
  --              the menu bar, which you can then see but not use.
  --
  -- There is no middle: topmost decides both whether the bar floats above
  -- windows *and* which strip it lands in. Auto-stepping aside when the menu
  -- bar is summoned is a dead end too — reaching a pill means moving the
  -- pointer into the strip, which is the same gesture that summons the menu
  -- bar, so the target moves out from under the cursor before it can be
  -- clicked.
  mode = os.getenv("SKETCHYBAR_MODE") or "below",
}
