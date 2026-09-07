local settings = require("settings")

require("bar")
require("default")
require("items")

-- Never call sbar.update() here: it does not return, so everything after it —
-- including hotload and end_config in sketchybarrc — silently never runs.
-- Items call their own update once at load instead.

-- notch_display_height only takes effect as a *change* in value, hence the
-- step through 0. "replace" also needs topmost, set in bar.lua.
if settings.mode == "replace" then
  sbar.bar({ notch_display_height = 0 })
  sbar.bar({ notch_display_height = settings.bar_height })
else
  sbar.bar({ notch_display_height = 0, y_offset = 0 })

  -- Sketchybar anchors to the menu bar's height, not the notch, so auto-hiding
  -- the menu bar drops the bar behind the notch. `_HIHideMenuBar` has been seen
  -- set but not applied, so measure where the bar landed instead. Deferred
  -- because there is no geometry until the bar is laid out, and re-run off
  -- ambient events because there is no "menu bar setting changed" event.
  local function align()
    local ok, info = pcall(sbar.query, "left_pill")
    if not ok or type(info) ~= "table" or type(info.bounding_rects) ~= "table" then
      return
    end

    local y
    for _, rect in pairs(info.bounding_rects) do
      if type(rect) == "table" and rect.origin then
        y = rect.origin[2]
        break
      end
    end
    if not y then
      return
    end

    -- `y` already includes the current offset, so this must be a delta, not an
    -- assignment. Read the offset back from the bar rather than tracking it in
    -- an upvalue, which desyncs if anything else moves the bar.
    local delta = settings.top_inset - y
    if math.abs(delta) >= 1 then
      local ok_bar, bar = pcall(sbar.query, "bar")
      local current = (ok_bar and type(bar) == "table" and tonumber(bar.y_offset)) or 0
      sbar.bar({ y_offset = math.max(0, current + delta) })
    end
  end

  sbar.delay(1, function()
    align()
  end)

  -- `updates = "on"` required: see default.lua.
  local aligner = sbar.add("item", "notch_aligner", {
    drawing = false,
    updates = "on",
  })
  aligner:subscribe(
    { "front_app_switched", "space_change", "display_change", "system_woke", "forced" },
    align
  )
end
