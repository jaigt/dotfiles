local colors = require("colors")
local settings = require("settings")

-- The icon is a *background* property, so this item can't take the global
-- background.drawing = false — that would take the icon with it. Hence the
-- transparent background.

local front_app = sbar.add("item", "front_app", {
  position = "left",
  icon = { drawing = false },
  background = {
    drawing = true,
    color = colors.transparent,
    border_width = 0,
    image = { drawing = true, scale = 0.44, padding_left = 10 },
  },
  label = {
    font = { family = settings.font, style = "Bold", size = 13.0 },
    color = colors.fg,
    padding_left = 34,
    padding_right = 12,
    max_chars = 22,
  },
})

-- Bundle id, not name: the process name ("wezterm-gui") won't resolve to an
-- icon. Unresolvable ids — briefly-focused background agents — make sketchybar
-- keep the *previous* icon and log a line per attempt, so the id is only
-- emitted when mdfind can name a bundle for it. mdfind failing outright
-- (empty, not "0") counts as resolvable, so indexing-off machines keep icons.
--
-- No `sh -c` wrapper: sbar.exec's popen() is already /bin/sh -c.
local function update(env)
  sbar.exec([[asn=$(lsappinfo front); ]]
    .. [[lsappinfo info -only name "$asn" | head -1 | sed -n 's/^"\([^"]*\)".*/\1/p'; ]]
    .. [[b=$(lsappinfo info -only bundleid "$asn" | sed -n 's/.*bundleID="\([^"]*\)".*/\1/p' | head -1); ]]
    .. [[if [ -n "$b" ]; then ]]
    .. [[c=$(mdfind -count "kMDItemCFBundleIdentifier == '$b'" 2>/dev/null); ]]
    .. [[[ "$c" != "0" ] && echo "$b"; ]]
    .. [[fi]],
    function(out)
      local lines = {}
      for line in out:gmatch("[^\n]+") do lines[#lines + 1] = line end
      local name = (env and env.INFO ~= "" and env.INFO) or lines[1]
      local bundle = lines[2]
      if not name then return end

      if bundle then
        front_app:set({
          label = { string = name, padding_left = 34 },
          background = { image = { string = "app." .. bundle, drawing = true } },
        })
      else
        -- Only drawing = false clears the old icon; an unresolvable string
        -- leaves it drawn.
        front_app:set({
          label = { string = name, padding_left = 10 },
          background = { image = { drawing = false } },
        })
      end
    end)
end

front_app:subscribe("front_app_switched", update)
front_app:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Mission Control'")
end)

update(nil)

return front_app
