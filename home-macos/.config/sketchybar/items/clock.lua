local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local clock = sbar.add("item", "clock", {
  position = "right",
  icon = {
    string = icons.clock,
    font = { family = settings.font, style = "Bold", size = 13.0 },
    color = colors.blue,
    padding_left = 10,
    padding_right = 6,
  },
  label = {
    font = { family = settings.font, style = "SemiBold", size = 13.0 },
    color = colors.fg,
    padding_right = 12,
  },
  update_freq = 15,
  popup = { align = "right" },
})

-- Labels are single-line, so every `cal` row needs its own item: month heading,
-- weekday heading, six week rows.
--
-- The explicit width is required: sketchybar under-measures a label starting
-- with spaces and clips its tail.
local CAL_ROWS = 8
local cal = {}
for i = 1, CAL_ROWS do
  cal[i] = sbar.add("item", "clock.cal" .. i, {
    position = "popup." .. clock.name,
    icon = { drawing = false },
    label = {
      string = "",
      font = {
        family = settings.mono,
        style = i == 1 and "Bold" or "Regular",
        size = 12.0,
      },
      color = i == 1 and colors.blue or (i == 2 and colors.gray or colors.fg),
      padding_left = 14,
      padding_right = 14,
    },
    background = { drawing = false, height = 18 },
    width = 172,
    drawing = false,
  })
end

local function update_clock()
  sbar.exec([[date '+%a %d %b  %-I:%M %p']], function(out)
    clock:set({ label = (out or ""):gsub("%s+$", "") })
  end)
end

clock:subscribe({ "routine", "forced" }, update_clock)

clock:subscribe("mouse.clicked", function()
  -- col -b flattens `cal`'s overstrike "today" marker, which renders as
  -- garbage; `expand` because a tab in a label has no defined width.
  -- [==[ ]==] because "[[:space:]]" would close a plain [[ ]].
  sbar.exec([==[sh -c "cal | col -b | expand | sed '/^[[:space:]]*$/d'"]==], function(out)
    local i = 1
    for line in (out or ""):gmatch("[^\n]+") do
      if i > CAL_ROWS then break end
      cal[i]:set({ drawing = true, label = line })
      i = i + 1
    end
    while i <= CAL_ROWS do
      cal[i]:set({ drawing = false })
      i = i + 1
    end
    clock:set({ popup = { drawing = "toggle" } })
  end)
end)

clock:subscribe("mouse.exited.global", function()
  clock:set({ popup = { drawing = false } })
end)

update_clock()

return clock
