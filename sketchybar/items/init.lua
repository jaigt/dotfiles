local colors = require("colors")
local settings = require("settings")

-- Right-side items are laid out rightmost-first, so that list reads
-- right-to-left on screen — first required ends up furthest right.
local logo      = require("items.logo")
local front_app = require("items.front_app")
local git       = require("items.git")

local media     = require("items.media")

local clock     = require("items.clock")
local battery   = require("items.battery")
local wifi      = require("items.wifi")
local volume    = require("items.volume")
local claude    = require("items.claude")

-- Members that hide themselves drop out of a bracket's span on their own, so
-- items can come and go without leaving a hole.
local pill = {
  drawing = true,
  color = colors.pill_bg,
  height = settings.pill_height,
  corner_radius = settings.pill_height / 2,
  border_width = 1,
  border_color = colors.pill_border,
}

sbar.add("bracket", "left_pill", { logo.name, front_app.name, git.name }, {
  background = pill,
})

-- An empty bracket still draws its background, so its last member has to hide
-- this bracket by name alongside itself.
sbar.add("bracket", "center_pill", { media.name }, {
  background = pill,
})

sbar.add("bracket", "right_pill", {
  claude.name, volume.name, wifi.name, battery.name, clock.name,
}, {
  background = pill,
})
