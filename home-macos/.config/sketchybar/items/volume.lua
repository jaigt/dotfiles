local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Event-driven, no polling: volume_change still fires reliably. Scroll to
-- adjust, click to mute.

local volume = sbar.add("item", "volume", {
  position = "right",
  icon = {
    font = { family = settings.font, style = "Bold", size = 14.0 },
    color = colors.violet,
    padding_left = 10,
    padding_right = 6,
  },
  label = {
    font = { family = settings.font, style = "SemiBold", size = 12.0 },
    color = colors.violet,
    padding_right = 10,
  },
})

local function render(vol, muted)
  local icon, color
  if muted or vol == 0 then
    icon, color = icons.volume._0, colors.gray
  elseif vol > 66 then
    icon, color = icons.volume._100, colors.violet
  elseif vol > 33 then
    icon, color = icons.volume._66, colors.violet
  else
    icon, color = icons.volume._33, colors.violet
  end
  volume:set({
    icon = { string = icon, color = color },
    label = { string = vol .. "%", color = color },
  })
end

-- volume_change hands the new level straight to the callback — no shell-out.
volume:subscribe("volume_change", function(env)
  local vol = tonumber(env.INFO)
  if vol then render(vol, vol == 0) end
end)

local function refresh()
  sbar.exec([[osascript -e 'set v to output volume of (get volume settings)' ]]
    .. [[-e 'set m to output muted of (get volume settings)' -e 'return (v as string) & "," & (m as string)']],
    function(out)
      local v, m = (out or ""):match("([%d]+),(%a+)")
      if v then render(tonumber(v), m == "true") end
    end)
end

volume:subscribe("forced", refresh)

volume:subscribe("mouse.clicked", function()
  sbar.exec([[osascript -e 'set volume output muted (not (output muted of (get volume settings)))']],
    function() refresh() end)
end)

volume:subscribe("mouse.scrolled", function(env)
  local delta = tonumber(env.SCROLL_DELTA) or 0
  if delta == 0 then return end
  -- Scroll deltas are small and can be fractional, so scale up and clamp.
  local step = math.floor(delta * 3 + 0.5)
  sbar.exec([[osascript -e 'set v to output volume of (get volume settings)' ]]
    .. [[-e 'set n to v + (]] .. step .. [[)' ]]
    .. [[-e 'if n > 100 then set n to 100' ]]
    .. [[-e 'if n < 0 then set n to 0' ]]
    .. [[-e 'set volume output volume n' -e 'return n as string']],
    function(out)
      local v = tonumber((out or ""):match("%d+"))
      if v then render(v, v == 0) end
    end)
end)

refresh()

return volume
