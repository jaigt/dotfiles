return {
  font = "CaskaydiaCove NF",
  -- Anything laid out in columns has to use this or it won't line up.
  mono = "CaskaydiaCove NFM",

  bar_height  = 36,
  pill_height = 26,
  notch_width = 210,

  -- A target, not an offset: init.lua measures where the bar actually lands
  -- and corrects the difference.
  top_inset = 32,

  -- The rest of the desktop grid lines up with this. See docs/sketchybar.md.
  edge_margin = 64,

  --   "below"    under the notch, but behind windows, so maximised windows
  --              hide it. Centred items are possible.
  --   "replace"  in the menu bar strip, above all windows — but it covers the
  --              menu bar, which you can then see but not use.
  -- No middle option: topmost decides both float-above-windows and which strip
  -- it lands in.
  mode = os.getenv("SKETCHYBAR_MODE") or "below",
}
