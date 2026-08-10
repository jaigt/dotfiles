local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- sbar.exec, never io.popen: `top` is slow enough that a blocking call freezes
-- the bar's whole event thread.

local logo = sbar.add("item", "logo", {
  position = "left",
  icon = {
    string = icons.logo,
    font = { family = settings.font, style = "Bold", size = 15.0 },
    color = colors.violet,
    padding_left = 12,
    padding_right = 12,
  },
  label = { drawing = false },
})

local function popup_row(name, icon, color)
  return sbar.add("item", name, {
    position = "popup." .. logo.name,
    icon = {
      string = icon,
      font = { family = settings.font, style = "Bold", size = 13.0 },
      color = color,
      padding_left = 12,
      padding_right = 8,
    },
    label = {
      string = "…",
      font = { family = settings.font, style = "Regular", size = 12.0 },
      color = colors.fg,
      padding_right = 14,
    },
    background = { drawing = false, height = 22 },
  })
end

local cpu_row    = popup_row("logo.cpu", icons.cpu, colors.red)
local mem_row    = popup_row("logo.mem", icons.memory, colors.yellow)
local disk_row   = popup_row("logo.disk", icons.disk, colors.blue)
local uptime_row = popup_row("logo.uptime", icons.uptime, colors.violet)

sbar.add("item", "logo.sep", {
  position = "popup." .. logo.name,
  icon = { drawing = false },
  label = { drawing = false },
  width = 0,
  background = {
    drawing = true,
    height = 1,
    corner_radius = 0,
    border_width = 0,
    color = colors.bg_p2,
    padding_left = 10,
    padding_right = 10,
  },
})

local proc_rows = {}
for i = 1, 3 do
  proc_rows[i] = sbar.add("item", "logo.proc" .. i, {
    position = "popup." .. logo.name,
    icon = {
      string = "•",
      font = { family = settings.font, style = "Bold", size = 13.0 },
      color = colors.gray,
      padding_left = 14,
      padding_right = 8,
    },
    label = {
      string = "…",
      font = { family = settings.font, style = "Regular", size = 12.0 },
      color = colors.fg_dim,
      padding_right = 14,
    },
    background = { drawing = false, height = 20 },
  })
end

local function refresh()
  sbar.exec([[sh -c 'top -l 1 -n 0 | grep -E "^CPU usage|^PhysMem"; sysctl -n vm.loadavg']],
    function(out)
      local idle = out:match("CPU usage:.-([%d%.]+)%% idle")
      -- "%.0f", not "%d": %d raises on a non-integral float, killing the
      -- callback before the memory row is set.
      local used = idle and string.format("%.0f", 100 - tonumber(idle)) or "?"
      local l1, l5, l15 = out:match("{%s*([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)%s*}")
      local load = l1 and (l1 .. " " .. l5 .. " " .. l15) or "?"
      cpu_row:set({ label = used .. "% cpu   ·   load " .. load })

      local mem_used = out:match("PhysMem:%s*(%S+) used") or "?"
      local mem_free = out:match("([%w%.]+) unused") or "?"
      mem_row:set({ label = mem_used .. " used   ·   " .. mem_free .. " free" })
    end)

  -- / is the sealed system volume; Data is the one with real free space.
  sbar.exec([[df -H /System/Volumes/Data | awk 'NR==2 {print $3" of "$2" ("$5")"}']],
    function(out)
      disk_row:set({ label = (out:gsub("%s+$", "")) })
    end)

  -- [==[ ]==] because "[[:space:]]" would close a plain [[ ]] early.
  sbar.exec([==[uptime | sed -E 's/.*up[[:space:]]+//; s/,[[:space:]]+[0-9]+ users?.*//']==],
    function(out)
      uptime_row:set({ label = "up " .. (out:gsub("%s+$", "")) })
    end)

  sbar.exec([[ps -A -o %cpu=,comm= -r | head -3]], function(out)
    local i = 1
    for line in out:gmatch("[^\n]+") do
      if i > 3 then break end
      local pct, cmd = line:match("^%s*([%d%.]+)%s+(.+)$")
      if pct then
        local name = cmd:match("([^/]+)$") or cmd
        -- Not left-padded: a leading space makes sketchybar under-measure the
        -- label and clip its tail.
        proc_rows[i]:set({ label = pct .. "%  " .. name:sub(1, 28) })
        i = i + 1
      end
    end
    while i <= 3 do
      proc_rows[i]:set({ label = "" })
      i = i + 1
    end
  end)
end

logo:subscribe("mouse.clicked", function()
  refresh()
  logo:set({ popup = { drawing = "toggle" } })
end)

logo:subscribe("mouse.exited.global", function()
  logo:set({ popup = { drawing = false } })
end)

return logo
