-- Kanagawa "hybrid" -- Dragon's background with Wave's colours.
-- `<leader>uc` cycles the variants live; ACTIVE is what a fresh nvim starts on.
--
-- Linux copy (home-linux). Noctalia's wallpaper templates render
-- lua/matugen.lua (machine-local, never in the repo); when it exists, a
-- "noctalia" scheme joins the cycle and becomes the default. Disable the
-- template in noctalia.toml and delete lua/matugen.lua for static Kanagawa.
--
-- Transparency is the terminal's job, not nvim's: nvim looks opaque only
-- because it paints its own bg over every cell, so the schemes below turn that
-- painting off. Floats stay opaque on purpose -- transparent floats mean text
-- over text.

-- base16-nvim, which matugen.lua renders the Noctalia palette through, is
-- declared in the shared plugins/init.lua -- see the note there.
local has_noctalia = vim.uv.fs_stat(vim.fn.stdpath("config") .. "/lua/matugen.lua") ~= nil

local ACTIVE = has_noctalia and "noctalia" or "kanagawa-hybrid"

--------------------------------------------------------------------------------
-- Kanagawa
--------------------------------------------------------------------------------
-- The hybrid is built as WAVE with Dragon's background family grafted on, not
-- the other way round: only 11 ui keys differ between the variants against 19
-- syntax colours, and this leaves Wave's syntax palette inherited from upstream
-- rather than frozen in a table here.
--
-- Both tables have to be spelled out because kanagawa.setup() does
-- `M.config = tbl_deep_extend("force", M.config, opts)` -- it ACCUMULATES across
-- calls rather than replacing. Once hybrid grafts Dragon's backgrounds onto the
-- wave theme, simply omitting the override on the next call leaves the graft in
-- place, so cycling to plain Wave would silently keep Dragon's backgrounds.
--
-- `fg` is deliberately NOT in either table -- it is a foreground, so the hybrid
-- keeps Wave's #DCD7BA.
--
-- `bg_gutter` is deliberately absent too, even though it differs between the
-- variants. kanagawa merges the theme-specific override OVER the "all" one, so
-- listing it here would beat the bg_gutter = "none" set below and paint the
-- opaque stripe back down the left edge under transparency.
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
  -- nested, and easy to miss: FloatFooter and the mini.* title/prompt groups
  -- read ui.float.bg directly rather than ui.bg_*, so leaving these out left
  -- four groups still painting Wave's #16161D
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

-- `variant` is one of "dragon" | "hybrid" | "wave". Plain Dragon needs no
-- overrides -- it is the untouched upstream theme.
local function setup_kanagawa(variant)
  local base = (variant == "dragon") and "dragon" or "wave"

  -- With transparent = true, Kanagawa still paints the gutter, which leaves a
  -- visible opaque stripe down the left edge. "none" clears it.
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

    -- Kanagawa clears every background under `transparent`, floats included, so
    -- the surfaces that must stay opaque get painted back by hand here.
    -- bg_p1 is one step UP from the background. (Careful with the names --
    -- Kanagawa's bg_m1 is *lighter* than bg in Dragon.)
    overrides = function(colors)
      local theme = colors.theme
      return {
        NormalFloat = { bg = theme.ui.bg_p1 },
        FloatBorder = { bg = theme.ui.bg_p1, fg = theme.ui.nontext },
        FloatTitle = { bg = theme.ui.bg_p1, fg = theme.ui.fg },
        -- The completion menu (blink.cmp) and which-key ride on Pmenu.
        Pmenu = { bg = theme.ui.bg_p1 },
        PmenuSel = { bg = theme.ui.bg_p2 },
      }
    end,
  })
end

--------------------------------------------------------------------------------
-- Variant switch
--------------------------------------------------------------------------------
local SCHEMES = { "kanagawa-dragon", "kanagawa-hybrid", "kanagawa-wave" }
if has_noctalia then
  table.insert(SCHEMES, 1, "noctalia")
end

local LUALINE_THEME = {
  ["noctalia"] = "auto",
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
  ["kanagawa-dragon"] = "kanagawa-dragon",
  ["kanagawa-hybrid"] = "kanagawa-wave",
  ["kanagawa-wave"] = "kanagawa-wave",
}

-- The current scheme is tracked here rather than read back from
-- `vim.g.colors_name`, because kanagawa sets that to plain "kanagawa" for every
-- variant -- cycling off it would never distinguish dragon from wave and would
-- stick on the first one.
local current = ACTIVE

-- lualine is configured in ui.lua, which loads after this file, so the restyle
-- is guarded on a cold start. The new theme has to be merged into the
-- *existing* config -- lualine.setup() replaces wholesale, so passing only
-- `options` would wipe the custom sections ui.lua defines.
local function apply(name)
  current = name
  if name == "noctalia" then
    -- Re-read the generated palette; base16 paints its highlights directly,
    -- there is no :colorscheme to call.
    package.loaded["matugen"] = nil
    require("matugen").setup()
  else
    -- Kanagawa has to be re-set up before the colorscheme call, not after: the
    -- variant (and, for the hybrid, the grafted palette) is baked in at setup
    -- time, and `:colorscheme` only re-renders whatever setup last produced.
    local variant = KANAGAWA_VARIANT[name]
    if variant then
      setup_kanagawa(variant)
    end
    vim.cmd.colorscheme(COLORSCHEME_CMD[name])
  end
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
end, { desc = "Cycle colorscheme (theme trial)" })

-- Exposed so ui.lua can theme lualine to match ACTIVE without duplicating the
-- mapping.
vim.g.lualine_theme = LUALINE_THEME[ACTIVE]

if ACTIVE == "noctalia" then
  require("matugen").setup()
else
  if KANAGAWA_VARIANT[ACTIVE] then
    setup_kanagawa(KANAGAWA_VARIANT[ACTIVE])
  end
  vim.cmd.colorscheme(COLORSCHEME_CMD[ACTIVE])
end

-- Noctalia re-renders matugen.lua on wallpaper change, then pkills -USR1 nvim.
-- Registered unconditionally: the default SIGUSR1 disposition would kill any
-- nvim without a handler, so every instance must own one even on Kanagawa.
local signal = vim.uv.new_signal()
signal:start(
  "sigusr1",
  vim.schedule_wrap(function()
    if current == "noctalia" then
      apply("noctalia")
    end
  end)
)
