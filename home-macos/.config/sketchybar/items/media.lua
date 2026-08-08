local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Now playing.
--
-- Sketchybar's own `media_change` event is deprecated as of macOS 26 (Apple
-- locked down the MediaRemote framework it relied on), so this listens for the
-- distributed notification Spotify posts instead — Spotify only, but genuinely
-- event-driven and still working.
--
-- Sole member of center_pill: every place that changes this item's visibility
-- must change the bracket's too, or an empty bracket draws a stray pill.

sbar.add("event", "spotify_change", "com.spotify.client.PlaybackStateChanged")

local media = sbar.add("item", "media", {
  position = "center",
  icon = {
    string = icons.media.note,
    font = { family = settings.font, style = "Bold", size = 13.0 },
    color = colors.green,
    padding_left = 10,
    padding_right = 6,
  },
  label = {
    font = { family = settings.font, style = "SemiBold", size = 12.0 },
    color = colors.fg_dim,
    padding_right = 10,
    max_chars = 36,
  },
  scroll_texts = true,
  drawing = false,
  updates = "on",
})

-- Sending Spotify *any* Apple Event while it is quitting brings it back from
-- the dead, and the AppleScript `is running` guard is not sufficient on its
-- own: quitting posts a PlaybackStateChanged notification *and* moves focus, so
-- this runs inside the ~150ms teardown window while `is running` is still true.
-- Measured: Cmd-Q at t=0.02s, gone at 0.15s, relaunched by this item at 0.27s.
--
-- Hence the two guards in front of the AppleScript, both of which matter:
--   sleep  lets a quit finish before Spotify is touched at all.
--   pgrep  a POSIX liveness check that sends no Apple Event, so unlike
--          `is running` it cannot itself relaunch anything.
--
-- Do not collapse this into a bare tell block, and do not drop the sleep.
local QUERY = "sleep 1; pgrep -x Spotify >/dev/null 2>&1 || { echo notrunning; exit 0; }; "
  .. [[osascript -e 'if application id "com.spotify.client" is running then' ]]
  .. [[-e 'tell application id "com.spotify.client"' ]]
  .. [[-e 'set s to player state as string' ]]
  .. [[-e 'if s is "stopped" then return "stopped"' ]]
  .. [[-e 'return s & tab & (name of current track) & tab & (artist of current track)' ]]
  .. [[-e 'end tell' ]]
  .. [[-e 'else' ]]
  .. [[-e 'return "notrunning"' ]]
  .. [[-e 'end if' 2>/dev/null]]

local function show(props)
  props.drawing = true
  media:set(props)
  sbar.set("center_pill", { drawing = true })
end

local function hide()
  media:set({ drawing = false })
  sbar.set("center_pill", { drawing = false })
end

local function update()
  sbar.exec(QUERY, function(out)
    out = (out or ""):gsub("%s+$", "")
    if out == "" or out == "notrunning" or out == "stopped" then
      hide()
      return
    end

    local state, track, artist = out:match("^([^\t]*)\t([^\t]*)\t?(.*)$")
    if not track or track == "" then
      hide()
      return
    end

    local label = track
    if artist and artist ~= "" then label = track .. " — " .. artist end

    show({
      icon = {
        string = state == "playing" and icons.media.play or icons.media.pause,
        color = state == "playing" and colors.green or colors.gray,
      },
      label = label,
    })
  end)
end

-- front_app_switched is a safety net: nothing is posted when Spotify quits, so
-- without it the item would sit there showing a stale track forever.
media:subscribe({ "spotify_change", "front_app_switched", "forced" }, update)

media:subscribe("mouse.clicked", function()
  sbar.exec([[osascript -e 'if application id "com.spotify.client" is running then ]]
    .. [[tell application id "com.spotify.client" to playpause' 2>/dev/null]],
    function() update() end)
end)

-- Populate once at load: there is no sbar.update() to force a first tick.
update()

return media
