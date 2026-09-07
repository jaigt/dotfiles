-- rose-pine is the system scheme, gruvbox-material the installed flip-back;
-- anything else is auditioned session-only via fzf's awesome_colorschemes
-- (<leader>sc). The ColorScheme autocmd below gives those the same
-- transparency treatment.

local ACTIVE = "rose-pine" -- 'rose-pine' | 'gruvbox-material'

require("rose-pine").setup({
	variant = "main",
	dark_variant = "main",
	styles = { transparency = true },
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
	-- rose-pine tints virtual text with `blend`, which composites against
	-- Normal's bg -- and transparency leaves that unset, so the tint lands on
	-- nothing. Same hues blended into base (#1e1e1e) at ~18% by hand.
	highlight_groups = {
		DiagnosticVirtualTextError = { fg = "#eb6f92", bg = "#432d33", italic = true },
		DiagnosticVirtualTextWarn = { fg = "#f6c177", bg = "#453b2e", italic = true },
		DiagnosticVirtualTextInfo = { fg = "#9ccfd8", bg = "#353e40", italic = true },
		DiagnosticVirtualTextHint = { fg = "#c4a7e7", bg = "#3c3742", italic = true },
	},
})

vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_foreground = "material"
vim.g.gruvbox_material_transparent_background = 2
vim.g.gruvbox_material_better_performance = 1
-- Default is 'grey', which renders diagnostics as comment-coloured text.
-- 'highlighted' backs them with the bg_visual_* tints, matching rose-pine.
vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
-- Local deviation, the inverse of rose-pine's graphite: the material tan
-- foregrounds desaturated at equal luminance, so text reads grey while the
-- hues stay stock. Mirrors the values in `theme`, wezterm, sketchybar, etc.
vim.g.gruvbox_material_colors_override = {
	fg0 = { "#c1c1c1", "251" },
	fg1 = { "#cacaca", "252" },
	grey0 = { "#737373", "243" },
	grey1 = { "#858585", "245" },
	grey2 = { "#9b9b9b", "247" },
}

local CLEAR_BG = {
	"Normal",
	"NormalNC",
	"NormalFloat",
	"FloatBorder",
	"FloatTitle",
	"EndOfBuffer",
	"SignColumn",
	"LineNr",
	"WinBar",
	"WinBarNC",
}

-- Returns a theme *table*, not a name: the middle section and the whole
-- inactive mode (non-selected winbar buffers) get their backgrounds stripped
-- so the statusline stays transparent like the rest of the UI.
local function lualine_theme()
	-- Theme modules compute colors from the colorscheme state at require
	-- time, so a cached table keeps the previous palette. Bust the cache.
	local mod = "lualine.themes." .. (vim.g.colors_name or "auto")
	package.loaded[mod] = nil
	local ok, theme = pcall(require, mod)
	if not ok then
		package.loaded["lualine.themes.auto"] = nil
		theme = require("lualine.themes.auto")
	end
	theme = vim.deepcopy(theme)
	for mode_name, mode in pairs(theme) do
		if type(mode) == "table" then
			if type(mode.c) == "table" then
				mode.c.bg = "NONE"
			end
			if mode_name == "inactive" then
				for _, section in pairs(mode) do
					if type(section) == "table" then
						section.bg = "NONE"
					end
				end
			end
		end
	end
	return theme
end

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		for _, group in ipairs(CLEAR_BG) do
			local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
			hl.bg = nil
			vim.api.nvim_set_hl(0, group, hl)
		end
		if package.loaded["lualine"] then
			local lualine = require("lualine")
			lualine.setup(vim.tbl_deep_extend("force", lualine.get_config(), {
				options = { theme = lualine_theme() },
			}))
		end
	end,
})

vim.cmd.colorscheme(ACTIVE == "rose-pine" and "rose-pine" or ACTIVE)
-- ui.lua hasn't loaded lualine yet at startup; it reads this at setup.
vim.g.lualine_theme = lualine_theme()
