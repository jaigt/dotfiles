-- Kanagawa palettes. Flip ACTIVE and save -- WezTerm hot-reloads the config.
--
-- Linux copy (home-linux). Noctalia's wallpaper templates render
-- colors-noctalia.lua next to this file (machine-local, never in the repo);
-- when it exists it wins. Disable the template in noctalia.toml and delete
-- that file to fall back to the static Kanagawa tables below.
do
  local ok, noctalia = pcall(require, 'colors-noctalia')
  if ok and type(noctalia) == 'table' then
    return noctalia
  end
end

-- Do NOT use WezTerm's built-in 'Kanagawa Dragon (Gogh)' scheme. It is
-- mislabelled: its background is #1f1f28 and its foreground #ddd8bb, which are
-- Wave's values, not Dragon's (#181616 / #c5c9c5), and the ANSI row is Wave's.
-- Everything below comes from rebelot/kanagawa.nvim's own `term` table.

local ACTIVE = 'kanagawa-hybrid' -- 'kanagawa-dragon' | 'kanagawa-hybrid' | 'kanagawa-wave'

local palettes = {}

--------------------------------------------------------------------------------
-- Kanagawa Dragon -- the muted, warm-charcoal variant.
--------------------------------------------------------------------------------
-- Upstream reuses Wave's colours for Dragon's bright row. Note bright-black is
-- #a6a69c, light enough that "dimmed" CLI output reads nearly as bright as body
-- text; #625e5a (dragonBlack6) is the fix if that bothers you.
palettes['kanagawa-dragon'] = {
  foreground = '#c5c9c5', -- dragonWhite
  background = '#181616', -- dragonBlack3

  cursor_bg = '#625e5a', -- dragonBlack6
  cursor_fg = '#181616',
  cursor_border = '#625e5a',

  selection_fg = '#c5c9c5',
  selection_bg = '#223249',

  scrollbar_thumb = '#282727', -- bg_p1
  split = '#282727',

  ansi = {
    '#0d0c0c', -- black   / dragonBlack0
    '#c4746e', -- red     / dragonRed
    '#8a9a7b', -- green   / dragonGreen2
    '#c4b28a', -- yellow  / dragonYellow
    '#8ba4b0', -- blue    / dragonBlue2
    '#a292a3', -- magenta / dragonPink
    '#8ea4a2', -- cyan    / dragonAqua
    '#C8C093', -- white
  },
  brights = {
    '#a6a69c', -- dragonGray
    '#E46876',
    '#87a987', -- dragonGreen
    '#E6C384',
    '#7FB4CA',
    '#938AA9',
    '#7AA89F',
    '#c5c9c5', -- dragonWhite
  },

  tab_bar = {
    background = '#181616',
    active_tab = { bg_color = '#181616', fg_color = '#c5c9c5' },
    inactive_tab = { bg_color = '#181616', fg_color = '#737c73' }, -- dragonAsh
    inactive_tab_hover = { bg_color = '#181616', fg_color = '#9e9b93' },
    new_tab = { bg_color = '#181616', fg_color = '#737c73' },
    new_tab_hover = { bg_color = '#181616', fg_color = '#c5c9c5' },
  },
}

--------------------------------------------------------------------------------
-- Kanagawa Hybrid -- Dragon's shell, Wave's colours.
--------------------------------------------------------------------------------
-- Dragon's background, cursor, selection and tab bar, carrying Wave's ANSI rows
-- and foreground. Hand-mixed; not an upstream variant.
palettes['kanagawa-hybrid'] = {
  foreground = '#DCD7BA', -- Wave's fujiWhite
  background = '#181616', -- Dragon's dragonBlack3

  cursor_bg = '#625e5a', -- Dragon's dragonBlack6
  cursor_fg = '#181616',
  cursor_border = '#625e5a',

  selection_fg = '#DCD7BA',
  selection_bg = '#223249',

  scrollbar_thumb = '#282727', -- Dragon's bg_p1
  split = '#282727',

  -- Wave's rows wholesale.
  ansi = {
    '#16161D',
    '#C34043',
    '#76946A',
    '#C0A36E',
    '#7E9CD8',
    '#957FB8',
    '#6A9589',
    '#C8C093',
  },
  brights = {
    '#727169',
    '#E82424',
    '#98BB6C',
    '#E6C384',
    '#7FB4CA',
    '#938AA9',
    '#7AA89F',
    '#DCD7BA',
  },

  tab_bar = {
    background = '#181616',
    active_tab = { bg_color = '#181616', fg_color = '#DCD7BA' },
    inactive_tab = { bg_color = '#181616', fg_color = '#737c73' },
    inactive_tab_hover = { bg_color = '#181616', fg_color = '#C8C093' },
    new_tab = { bg_color = '#181616', fg_color = '#737c73' },
    new_tab_hover = { bg_color = '#181616', fg_color = '#DCD7BA' },
  },
}

--------------------------------------------------------------------------------
-- Kanagawa Wave -- the original, saturated variant. Here for comparison.
--------------------------------------------------------------------------------
palettes['kanagawa-wave'] = {
  foreground = '#DCD7BA', -- fujiWhite
  background = '#1F1F28', -- sumiInk3

  cursor_bg = '#54546D',
  cursor_fg = '#1F1F28',
  cursor_border = '#54546D',

  selection_fg = '#DCD7BA',
  selection_bg = '#223249',

  scrollbar_thumb = '#2A2A37',
  split = '#2A2A37',

  ansi = {
    '#16161D',
    '#C34043',
    '#76946A',
    '#C0A36E',
    '#7E9CD8',
    '#957FB8',
    '#6A9589',
    '#C8C093',
  },
  brights = {
    '#727169',
    '#E82424',
    '#98BB6C',
    '#E6C384',
    '#7FB4CA',
    '#938AA9',
    '#7AA89F',
    '#DCD7BA',
  },

  tab_bar = {
    background = '#1F1F28',
    active_tab = { bg_color = '#1F1F28', fg_color = '#DCD7BA' },
    inactive_tab = { bg_color = '#1F1F28', fg_color = '#727169' },
    inactive_tab_hover = { bg_color = '#1F1F28', fg_color = '#C8C093' },
    new_tab = { bg_color = '#1F1F28', fg_color = '#727169' },
    new_tab_hover = { bg_color = '#1F1F28', fg_color = '#DCD7BA' },
  },
}

-- Returned as a plain table so other modules can reach individual swatches --
-- tabs.lua tints the tab index with `ansi[5]`.
local M = palettes[ACTIVE]
if not M then
  error("colors.lua: unknown ACTIVE palette '" .. tostring(ACTIVE) .. "'")
end

return M
