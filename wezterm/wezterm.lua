-- WezTerm searches ~/.config/wezterm for modules, so a plain `require 'name'`
-- resolves to a sibling even though this file is a symlink out of the repo.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

require('appearance').apply(config)
require('tabs').apply(config)
require('keys').apply(config)

return config
