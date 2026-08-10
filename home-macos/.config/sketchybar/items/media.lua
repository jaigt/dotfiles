local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Sketchybar's `media_change` is dead on macOS 26 (MediaRemote locked down),
-- hence Spotify's own distributed notification instead.
--
-- Sole member of center_pill: change this item's visibility and you must change
-- the bracket's too, or an empty bracket draws a stray pill.

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

-- Any Apple Event sent to Spotify mid-quit relaunches it, and quitting fires
-- this very notification while `is running` is still true. The sleep waits the
-- teardown out; pgrep re-checks without sending an event. Drop neither.
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

-- Spotify posts nothing on quit, so front_app_switched is what clears a
-- stale track.
media:subscribe({ "spotify_change", "front_app_switched", "forced" }, update)

media:subscribe("mouse.clicked", function()
  sbar.exec([[osascript -e 'if application id "com.spotify.client" is running then ]]
    .. [[tell application id "com.spotify.client" to playpause' 2>/dev/null]],
    function() update() end)
end)

update()

return media
