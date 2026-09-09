-- UI
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("mini.sessions").setup({
	autoread = false,
	autowrite = true,
})

-- Editing/Coding:
require("mini.ai").setup()
require("mini.pairs").setup()
require("mini.surround").setup({
	mappings = {
		add = "gsa",
		delete = "gsd",
		replace = "gsr",
		find = "gsf",
		find_left = "gsF",
		highlight = "gsh",
		update_n_lines = "gsn",
	},
})

-- Dashboard:
local starter = require("mini.starter")

local HEADER = [[
░░░    ░░ ░░    ░░ ░░ ░░░    ░░░
▒▒▒▒   ▒▒ ▒▒    ▒▒ ▒▒ ▒▒▒▒  ▒▒▒▒
▒▒ ▒▒  ▒▒ ▒▒    ▒▒ ▒▒ ▒▒ ▒▒▒▒ ▒▒
▓▓  ▓▓ ▓▓  ▓▓  ▓▓  ▓▓ ▓▓  ▓▓  ▓▓
██   ████   ████   ██ ██      ██]]

starter.setup({
	header = HEADER,
	silent = true,

	-- Empty section name suppresses the label line. First letters stay unique so
	-- `evaluate_single` launches each item on one key.
	items = {
		{ name = "Files", action = "FzfLua files", section = "" },
		{ name = "Recent", action = "FzfLua oldfiles", section = "" },
		{ name = "Explore", action = "Oil --float", section = "" },
		{ name = "Sessions", action = "lua MiniSessions.select()", section = "" },
	},

	content_hooks = {
		starter.gen_hook.adding_bullet("✦ "),
		starter.gen_hook.aligning("center", "center"),
	},

	footer = function()
		-- `info = false`: the default spawns git subprocesses per plugin, on every
		-- refresh. The count alone comes from the lockfile.
		local n = #(vim.pack.get(nil, { info = false }) or {})
		return ("%d plugins · nvim %s\n%s"):format(n, tostring(vim.version()), tostring(vim.fn.getcwd()))
	end,

	evaluate_single = true,
})

local function set_starter_hl()
	vim.api.nvim_set_hl(0, "MiniStarterHeader", { link = "Title" })
	vim.api.nvim_set_hl(0, "MiniStarterFooter", { link = "Comment" })
	-- Hotkey-launcher look: accent first letter, plain dash, no "selected" item.
	-- A link can't add `bold`, so copy the colour out instead.
	local warn = vim.api.nvim_get_hl(0, { name = "WarningMsg", link = false })
	vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { fg = warn.fg, bold = true })
	vim.api.nvim_set_hl(0, "MiniStarterItemBullet", { link = "Comment" })
	vim.api.nvim_set_hl(0, "MiniStarterCurrent", { link = "MiniStarterItem" })
end

-- Loading a colorscheme clears all highlight groups, hence re-applying.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("jay_starter_hl", { clear = true }),
	callback = set_starter_hl,
})
set_starter_hl()
