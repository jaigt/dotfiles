-- `<leader>uc` cycles variants live; ACTIVE is what a fresh nvim starts on.
--
-- Transparency is the terminal's job: nvim looks opaque only because it paints
-- its own bg over every cell, so that painting is off below. Floats stay
-- opaque — transparent floats mean text over text.

local ACTIVE = "rose-pine" -- "rose-pine" | "kanagawa-dragon" | "kanagawa-hybrid" | "kanagawa-wave"

--------------------------------------------------------------------------------
-- Kanagawa
--------------------------------------------------------------------------------
-- Hybrid is WAVE with Dragon's backgrounds grafted on, not the reverse: far
-- fewer ui keys differ than syntax colours, so Wave's syntax palette stays
-- inherited rather than frozen in a table here.
--
-- kanagawa.setup() ACCUMULATES (tbl_deep_extend on each call), so both tables
-- must be spelled out — omitting an override does not undo it, and cycling
-- back to Wave would silently keep Dragon's backgrounds.
--
-- `fg` is absent on purpose so the hybrid keeps Wave's foreground. `bg_gutter`
-- too: theme overrides beat the "all" one, so listing it here would defeat the
-- bg_gutter = "none" below and repaint the opaque stripe.
local DRAGON_UI = {
  bg = "#181616",
  bg_dim = "#12120f",
  bg_m1 = "#1D1C19",
  bg_m2 = "#12120f",
  bg_m3 = "#0d0c0c",
  bg_p1 = "#282727",
  bg_p2 = "#393836",
  nontext = "#625e5a",
  special = "#7a8382",
  whitespace = "#625e5a",
  -- Easy to miss: FloatFooter and the mini.* title/prompt groups read
  -- ui.float.bg directly, not ui.bg_*, so omitting these leaves them opaque.
  float = { bg = "#0d0c0c", bg_border = "#0d0c0c" },
}

local WAVE_UI = {
  bg = "#1F1F28",
  bg_dim = "#181820",
  bg_m1 = "#1a1a22",
  bg_m2 = "#181820",
  bg_m3 = "#16161D",
  bg_p1 = "#2A2A37",
  bg_p2 = "#363646",
  nontext = "#54546D",
  special = "#938AA9",
  whitespace = "#54546D",
  float = { bg = "#16161D", bg_border = "#16161D" },
}

-- Plain Dragon needs no overrides; it is the untouched upstream theme.
local function setup_kanagawa(variant)
  local base = (variant == "dragon") and "dragon" or "wave"

  -- Kanagawa still paints the gutter under transparent = true.
  local theme_overrides = { all = { ui = { bg_gutter = "none" } } }

  if variant == "hybrid" then
    theme_overrides.wave = { ui = DRAGON_UI }
  elseif variant == "wave" then
    theme_overrides.wave = { ui = WAVE_UI }
  end

  require("kanagawa").setup({
    theme = base,
    background = { dark = base }, -- pinned, so `vim.o.background` can't flip
    -- us into the light Lotus variant
    transparent = true,
    colors = { theme = theme_overrides },

    -- `transparent` clears floats too, so opaque surfaces are painted back by
    -- hand. Careful: Kanagawa's bg_m1 is *lighter* than bg in Dragon.
    overrides = function(colors)
      local theme = colors.theme
      return {
        NormalFloat = { bg = theme.ui.bg_p1 },
        FloatBorder = { bg = theme.ui.bg_p1, fg = theme.ui.nontext },
        FloatTitle = { bg = theme.ui.bg_p1, fg = theme.ui.fg },
        Pmenu = { bg = theme.ui.bg_p1 },
        PmenuSel = { bg = theme.ui.bg_p2 },
      }
    end,
  })
end

--------------------------------------------------------------------------------
-- Rosé Pine
--------------------------------------------------------------------------------
local function setup_rose_pine()
  require("rose-pine").setup({
    -- Pinned: the default "auto" follows `vim.o.background` and would flip to
    -- the light Dawn variant.
    variant = "main",
    dark_variant = "main",

    styles = {
      transparency = true,
    },

    -- "Graphite": upstream's background ramp fully desaturated at the same
    -- lightness. The highlight_groups below resolve these names, so floats
    -- and selection pick the values up automatically.
    palette = {
      main = {
        _nc = "#1a1a1a",
        base = "#1e1e1e",
        surface = "#262626",
        overlay = "#2f2f2f",
        highlight_low = "#272727",
        highlight_med = "#484848",
        highlight_high = "#5b5b5b",
      },
    },

    -- `transparency = true` clears floats too; opaque surfaces painted back.
    highlight_groups = {
      NormalFloat = { bg = "surface" },
      FloatBorder = { bg = "surface", fg = "highlight_high" },
      FloatTitle = { bg = "surface", fg = "text" },
      Pmenu = { bg = "surface" },
      PmenuSel = { bg = "highlight_med" },
    },
  })
end

--------------------------------------------------------------------------------
-- Variant switch
--------------------------------------------------------------------------------
local SCHEMES = { "rose-pine", "kanagawa-dragon", "kanagawa-hybrid", "kanagawa-wave" }

local LUALINE_THEME = {
  ["rose-pine"] = "rose-pine", -- ships with rose-pine/neovim, not with lualine
  ["kanagawa-dragon"] = "kanagawa",
  ["kanagawa-hybrid"] = "kanagawa",
  ["kanagawa-wave"] = "kanagawa",
}

local KANAGAWA_VARIANT = {
  ["kanagawa-dragon"] = "dragon",
  ["kanagawa-hybrid"] = "hybrid",
  ["kanagawa-wave"] = "wave",
}

local COLORSCHEME_CMD = {
  ["rose-pine"] = "rose-pine-main",
  ["kanagawa-dragon"] = "kanagawa-dragon",
  ["kanagawa-hybrid"] = "kanagawa-wave",
  ["kanagawa-wave"] = "kanagawa-wave",
}

-- Tracked here, not read off `vim.g.colors_name`: kanagawa sets that to plain
-- "kanagawa" for every variant, so cycling off it would stick on the first.
local current = ACTIVE

-- ui.lua loads after this file, hence the cold-start guard. Merge into the
-- existing config: lualine.setup() replaces wholesale, so passing `options`
-- alone would wipe ui.lua's custom sections.
local function apply(name)
  current = name
  -- setup() before :colorscheme, not after: the variant is baked in at setup
  -- time and :colorscheme only re-renders what setup last produced.
  local variant = KANAGAWA_VARIANT[name]
  if variant then
    setup_kanagawa(variant)
  elseif name == "rose-pine" then
    setup_rose_pine()
  end
  vim.cmd.colorscheme(COLORSCHEME_CMD[name])
  if package.loaded["lualine"] then
    local lualine = require("lualine")
    local cfg = vim.tbl_deep_extend("force", lualine.get_config(), {
      options = { theme = LUALINE_THEME[name] },
    })
    lualine.setup(cfg)
  end
  vim.notify("colorscheme: " .. name, vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>uc", function()
  local i = 1
  for idx, name in ipairs(SCHEMES) do
    if name == current then
      i = idx
      break
    end
  end
  apply(SCHEMES[(i % #SCHEMES) + 1])
end, { desc = "Cycle colorscheme" })

-- Exposed so ui.lua can match ACTIVE without duplicating the mapping.
vim.g.lualine_theme = LUALINE_THEME[ACTIVE]

if KANAGAWA_VARIANT[ACTIVE] then
  setup_kanagawa(KANAGAWA_VARIANT[ACTIVE])
elseif ACTIVE == "rose-pine" then
  setup_rose_pine()
end
vim.cmd.colorscheme(COLORSCHEME_CMD[ACTIVE])
