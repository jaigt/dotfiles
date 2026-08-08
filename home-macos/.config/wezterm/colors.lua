-- Terminal palettes. Flip ACTIVE and save -- WezTerm hot-reloads the config.
--
-- Do NOT use WezTerm's built-in 'Kanagawa Dragon (Gogh)' scheme. It is
-- mislabelled: its background is #1f1f28 and its foreground #ddd8bb, which are
-- Wave's values, not Dragon's (#181616 / #c5c9c5), and the ANSI row is Wave's.
-- Everything below comes from rebelot/kanagawa.nvim's own `term` table.

local ACTIVE = 'rose-pine' -- 'rose-pine' | 'kanagawa-dragon' | 'kanagawa-hybrid' | 'kanagawa-wave'

local palettes = {}

--------------------------------------------------------------------------------
-- Rosé Pine (main) -- the system theme.
--------------------------------------------------------------------------------
-- Verbatim from rose-pine/alacritty -> dist/rose-pine.toml. There's no
-- rose-pine/wezterm port, and WezTerm's built-in `rose-pine` scheme (Gogh's)
-- swaps the green and blue slots, so the Alacritty dist is the source here.
--
-- Note how the ANSI slots map -- upstream deliberately does NOT keep the hue
-- names aligned with the slot names, because Rosé Pine has no true green and
-- no true cyan:
--
--   green slot   -> pine (#31748f, a blue-teal)
--   blue slot    -> foam (#9ccfd8, pale cyan)
--   cyan slot    -> rose (#ebbcba, warm pink)
--
-- So `ls` directories come out teal and `git diff` additions come out blue.
-- That's the intended Rosé Pine look, not a mistake -- don't "fix" it.
-- The background family here is "graphite": upstream's ramp fully desaturated,
-- same lightness (base #191724 -> #1e1e1e etc.), matching the nvim palette
-- override. Foregrounds and the colour rows are stock Rosé Pine.
palettes['rose-pine'] = {
  foreground = '#e0def4', -- text
  background = '#1e1e1e', -- base (graphite)

  cursor_bg = '#5b5b5b', -- highlight-high (graphite)
  cursor_fg = '#e0def4',
  cursor_border = '#5b5b5b',

  selection_fg = '#e0def4',
  selection_bg = '#484848', -- highlight-med (graphite)

  scrollbar_thumb = '#2f2f2f', -- overlay (graphite)
  split = '#2f2f2f',

  ansi = {
    '#2f2f2f', -- black   / overlay (graphite)
    '#eb6f92', -- red     / love
    '#31748f', -- green   / pine
    '#f6c177', -- yellow  / gold
    '#9ccfd8', -- blue    / foam
    '#c4a7e7', -- magenta / iris
    '#ebbcba', -- cyan    / rose
    '#e0def4', -- white   / text
  },
  -- Rosé Pine's bright row is identical to the normal row apart from black,
  -- which steps overlay -> muted. Upstream does this on purpose: the palette
  -- has one tone per hue, so a synthesised brighter row would have to invent
  -- colours that aren't in the theme.
  brights = {
    '#6e6a86', -- muted
    '#eb6f92',
    '#31748f',
    '#f6c177',
    '#9ccfd8',
    '#c4a7e7',
    '#ebbcba',
    '#e0def4',
  },

  tab_bar = {
    background = '#1e1e1e',
    active_tab = { bg_color = '#1e1e1e', fg_color = '#e0def4' },
    inactive_tab = { bg_color = '#1e1e1e', fg_color = '#6e6a86' }, -- muted
    inactive_tab_hover = { bg_color = '#1e1e1e', fg_color = '#908caa' }, -- subtle
    new_tab = { bg_color = '#1e1e1e', fg_color = '#6e6a86' },
    new_tab_hover = { bg_color = '#1e1e1e', fg_color = '#e0def4' },
  },
}

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
