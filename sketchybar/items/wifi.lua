local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- No SSID on purpose: macOS redacts it without Location Services auth, which
-- a launchd-run CLI can't request. There is no route to the name.
-- Polls because wifi_change stopped firing in Sonoma.

local wifi = sbar.add("item", "wifi", {
  position = "right",
  icon = {
    font = { family = settings.font, style = "Bold", size = 14.0 },
    padding_left = 10,
    padding_right = 6,
  },
  label = {
    font = { family = settings.font, style = "SemiBold", size = 12.0 },
    color = colors.fg_dim,
    padding_right = 10,
  },
  update_freq = 30,
  popup = { align = "right" },
})

for _, row in ipairs({ { "ip", "IP " }, { "router", "GW " } }) do
  sbar.add("item", "wifi." .. row[1], {
    position = "popup." .. wifi.name,
    icon = {
      string = row[2],
      font = { family = settings.font, style = "Bold", size = 12.0 },
      color = colors.blue,
      padding_left = 14,
      padding_right = 8,
    },
    label = {
      string = "…",
      font = { family = settings.mono, style = "Regular", size = 12.0 },
      color = colors.fg,
      padding_right = 14,
    },
    background = { drawing = false, height = 22 },
  })
end

local function update()
  sbar.exec("ipconfig getifaddr en0", function(out)
    local ip = (out or ""):gsub("%s+", "")
    if ip ~= "" then
      wifi:set({
        icon = { string = icons.wifi, color = colors.blue },
        label = { drawing = false },
      })
    else
      wifi:set({
        icon = { string = icons.wifi_off, color = colors.gray },
        label = { string = "offline", color = colors.gray, drawing = true },
      })
    end
  end)
end

wifi:subscribe({ "routine", "system_woke", "forced" }, update)

wifi:subscribe("mouse.clicked", function()
  sbar.exec([[sh -c 'ipconfig getifaddr en0 || echo "not connected"; ]]
    .. [[netstat -rn | awk "/^default/ && \$NF ~ /en0/ {print \$2; exit}"']],
    function(out)
      local lines = {}
      for line in (out or ""):gmatch("[^\n]+") do lines[#lines + 1] = line end
      sbar.set("wifi.ip", { label = lines[1] or "not connected" })
      sbar.set("wifi.router", { label = lines[2] or "—" })
      wifi:set({ popup = { drawing = "toggle" } })
    end)
end)

wifi:subscribe("mouse.exited.global", function()
  wifi:set({ popup = { drawing = false } })
end)

update()

return wifi
