local settings = require("settings")

require("bar")
require("default")
require("items")

-- There is deliberately no sbar.update() here, and there must not be: it does
-- not return. It flushes and then enters the event loop, so anything after it
-- in this file — and everything after require("init") back in sketchybarrc,
-- including hotload and end_config — silently never runs. Items populate
-- themselves by calling their own update once at load instead.

-- --- position --------------------------------------------------------------
--
-- "replace" needs both topmost (set in bar.lua; with it off the bar stays below
-- the notch whatever else is set) and notch_display_height as an actual
-- *change* in value — assigning what it already holds is a no-op, hence the
-- step through 0.
if settings.mode == "replace" then
  sbar.bar({ notch_display_height = 0 })
  sbar.bar({ notch_display_height = settings.bar_height })
else
  sbar.bar({ notch_display_height = 0, y_offset = 0 })

  -- Keep the bar clear of the notch regardless of the menu bar setting.
  --
  -- Sketchybar anchors to the *menu bar's* height, not to the notch: turn on
  -- menu bar auto-hide and there is nothing to anchor to, so the bar rises to
  -- y=0 and sits behind the notch. `_HIHideMenuBar` cannot be trusted to answer
  -- this — it has been observed set and simply not applied — so measure where
  -- the bar actually landed instead. Deferred because there is no geometry to
  -- measure until the bar has been laid out.
  --
  -- It also has to RE-RUN: there is no sketchybar event for "the menu bar
  -- setting changed", so this rides on the ambient ones; `front_app_switched`
  -- alone fires often enough to self-correct within a keystroke of normal use.
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

    -- Relative, not absolute: `y` is where the bar landed *with the current
    -- offset already applied*, so assigning `top_inset - y` is only correct on
    -- the very first run and compounds after that. The delta also corrects in
    -- both directions, not just when the bar is too high.
    --
    -- The current offset is READ BACK from the bar rather than kept in an
    -- upvalue: a local accumulator desyncs the moment anything else moves the
    -- bar (`sketchybar --bar y_offset=...` from a shell), and the next
    -- correction then overshoots by exactly the amount it was wrong.
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

  -- `updates = "on"` is required, not decorative: a `drawing = false` item
  -- inherits `when_shown` and would never receive an event again. Same trap
  -- git/media/claude document.
  local aligner = sbar.add("item", "notch_aligner", {
    drawing = false,
    updates = "on",
  })
  aligner:subscribe(
    { "front_app_switched", "space_change", "display_change", "system_woke", "forced" },
    align
  )
end
