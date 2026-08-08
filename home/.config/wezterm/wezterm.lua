-- WezTerm's entry point. Every module exports apply(config) and mutates the
-- shared config table in place.
--
-- WezTerm searches ~/.config/wezterm for lua modules, so the plain
-- `require 'name'` below resolves to a sibling of this file even though this
-- file is a symlink out of the dotfiles repo.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

require('appearance').apply(config)
require('tabs').apply(config)
require('keys').apply(config)

return config
