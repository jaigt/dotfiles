local colors = require("colors")
local settings = require("settings")

-- The focused application, with its real macOS icon via sketchybar's built-in
-- `app.<bundle-id>` image source.
--
-- The image is a *background* property, so this item can't take the global
-- background.drawing = false that leaves pill-drawing to the brackets — that
-- would take the icon with it. It draws a fully transparent background instead.

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

-- Match on bundle id, not name: System Events reports the *process* name —
-- WezTerm's is "wezterm-gui", which sketchybar can't resolve to an app icon.
--
-- Not every bundle id can be turned into an icon: background agents like
-- com.apple.LocalAuthentication.UIAgent take focus briefly and `app.<id>` can't
-- resolve them. sketchybar answers that by logging "Invalid application name"
-- and *keeping the bitmap it already had*, so the previous app's icon sits next
-- to the new app's name until something resolvable comes along — and the log
-- fills up at one line per attempt.
--
-- So the id is only emitted when Spotlight can name a bundle for it, which is
-- the same question `app.<id>` asks. mdfind failing outright (empty, not "0")
-- counts as resolvable, so a machine with indexing off keeps its icons.
--
-- No `sh -c '...'` wrapper: sbar.exec's popen() is already /bin/sh -c, and the
-- second level only forced the sed and mdfind quoting to be escaped twice.
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
      -- env.INFO carries the app name on front_app_switched, and is empty on
      -- the initial forced update.
      local name = (env and env.INFO ~= "" and env.INFO) or lines[1]
      local bundle = lines[2]
      if not name then return end

      if bundle then
        front_app:set({
          label = { string = name, padding_left = 34 },
          background = { image = { string = "app." .. bundle, drawing = true } },
        })
      else
        -- image.drawing = false is what actually clears the old icon; assigning
        -- an unresolvable string would leave it drawn.
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
