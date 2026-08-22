-- rose-pine is the only installed scheme; anything else is auditioned
-- session-only via fzf's awesome_colorschemes (<leader>sc). The ColorScheme
-- autocmd below gives those the same transparency treatment.

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
})

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

vim.cmd.colorscheme("rose-pine-main")
-- ui.lua hasn't loaded lualine yet at startup; it reads this at setup.
vim.g.lualine_theme = lualine_theme()
