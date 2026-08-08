local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- How many Claude Code sessions are alive.

local claude = sbar.add("item", "claude", {
  position = "right",
  icon = {
    string = icons.claude,
    font = { family = settings.font, style = "Bold", size = 13.0 },
    color = colors.orange,
    padding_left = 10,
    padding_right = 6,
  },
  label = {
    font = { family = settings.font, style = "SemiBold", size = 12.0 },
    color = colors.orange,
    padding_right = 10,
  },
  drawing = false,
  updates = "on",
  update_freq = 15,
  popup = { align = "right" },
})

-- Rows are pre-declared and hidden rather than added and removed each time the
-- popup opens.
local MAX_ROWS = 5
local rows = {}
for i = 1, MAX_ROWS do
  rows[i] = sbar.add("item", "claude.s" .. i, {
    position = "popup." .. claude.name,
    icon = {
      string = icons.claude,
      font = { family = settings.font, style = "Bold", size = 11.0 },
      color = colors.orange,
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
    drawing = false,
  })
end

-- -x, not -f: matching the full command line would also catch the Claude
-- desktop app, this config's own shell-outs, and any editor with "claude" in a
-- path.
local function update()
  sbar.exec("pgrep -x claude | wc -l | tr -d ' '", function(out)
    -- match, not gsub: gsub returns *two* values (the string and the
    -- substitution count), and tonumber's second argument is the numeric base
    -- — so tonumber(s:gsub(...)) throws "base out of range" and silently kills
    -- the callback.
    local count = tonumber((out or ""):match("%d+")) or 0
    if count > 0 then
      claude:set({ drawing = true, label = tostring(count) })
    else
      claude:set({ drawing = false, popup = { drawing = false } })
    end
  end)
end

claude:subscribe({ "routine", "forced" }, update)

claude:subscribe("mouse.clicked", function()
  sbar.exec([[sh -c 'for p in $(pgrep -x claude); do ]]
    .. [[lsof -a -p $p -d cwd -Fn 2>/dev/null | awk "/^n/ {print substr(\$0,2); exit}"; ]]
    .. [[done']],
    function(out)
      local i = 1
      local home = os.getenv("HOME")
      for line in (out or ""):gmatch("[^\n]+") do
        if i > MAX_ROWS then break end
        local dir = line
        if home and dir:sub(1, #home) == home then dir = "~" .. dir:sub(#home + 1) end
        rows[i]:set({ drawing = true, label = dir })
        i = i + 1
      end
      while i <= MAX_ROWS do
        rows[i]:set({ drawing = false })
        i = i + 1
      end
      claude:set({ popup = { drawing = "toggle" } })
    end)
end)

claude:subscribe("mouse.exited.global", function()
  claude:set({ popup = { drawing = false } })
end)

-- Populate once at load: there is no sbar.update() to force a first tick.
update()

return claude
