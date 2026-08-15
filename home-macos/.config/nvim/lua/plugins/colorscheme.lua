local ACTIVE = "rose-pine"

local SCHEMES = {
	"rose-pine",
	"kanagawa-dragon",
	"gruvbox-material",
	"everforest",
	"nord",
}

local function setup_rose_pine()
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
end

local function setup_gruvbox_material()
	vim.o.background = "dark"
	vim.g.gruvbox_material_background = "medium"
	vim.g.gruvbox_material_transparent_background = 1
	vim.g.gruvbox_material_better_performance = 1
end

local function setup_everforest()
	vim.o.background = "dark"
	vim.g.everforest_background = "medium"
	vim.g.everforest_transparent_background = 1
	vim.g.everforest_better_performance = 1
end

local SETUP = {
	["rose-pine"] = setup_rose_pine,
	["gruvbox-material"] = setup_gruvbox_material,
	["everforest"] = setup_everforest,
}

local LUALINE_EXCEPTIONS = {
	["kanagawa-dragon"] = "kanagawa",
}

local function lualine_theme(name)
	return LUALINE_EXCEPTIONS[name] or name
end

local COLORSCHEME_CMD = {
	["rose-pine"] = "rose-pine-main",
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

local current = ACTIVE

local function activate(name)
	local setup = SETUP[name]
	if setup then
		setup()
	end
	vim.cmd.colorscheme(COLORSCHEME_CMD[name] or name)
	for _, group in ipairs(CLEAR_BG) do
		local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
		hl.bg = nil
		vim.api.nvim_set_hl(0, group, hl)
	end
end

local function apply(name)
	current = name
	activate(name)
	if package.loaded["lualine"] then
		local lualine = require("lualine")
		local cfg = vim.tbl_deep_extend("force", lualine.get_config(), {
			options = { theme = lualine_theme(name) },
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

vim.keymap.set("n", "<leader>uC", function()
	vim.ui.select(SCHEMES, { prompt = "Colorscheme" }, function(choice)
		if choice then
			apply(choice)
		end
	end)
end, { desc = "Pick colorscheme" })

vim.g.lualine_theme = lualine_theme(ACTIVE)

activate(ACTIVE)
