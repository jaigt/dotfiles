local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- power_source_change fires on plug/unplug; the slow routine tick catches the
-- charge level drifting between those events.

local battery = sbar.add("item", "battery", {
  position = "right",
  icon = {
    font = { family = settings.font, style = "Bold", size = 14.0 },
    padding_left = 10,
    padding_right = 6,
  },
  label = {
    font = { family = settings.font, style = "SemiBold", size = 12.0 },
    padding_right = 10,
  },
  update_freq = 60,
})

local function update()
  sbar.exec("pmset -g batt", function(out)
    out = out or ""
    local charge = tonumber(out:match("(%d+)%%"))
    if not charge then return end

    local icon, color
    if out:find("AC Power") then
                  icon, color = icons.battery.charging, colors.good
    elseif charge > 80 then
      icon, color = icons.battery._100, colors.fg
    elseif charge > 60 then
      icon, color = icons.battery._75, colors.fg
    elseif charge > 30 then
      icon, color = icons.battery._50, colors.warn
    elseif charge > 10 then
      icon, color = icons.battery._25, colors.warn
    else
      icon, color = icons.battery._0, colors.urgent
    end

    battery:set({
      icon = { string = icon, color = color },
      label = { string = charge .. "%", color = color },
    })
  end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke", "forced" }, update)

-- Populate once at load: there is no sbar.update() to force a first tick.
update()

return battery
