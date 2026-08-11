local starter = require("mini.starter")

local HEADER = [[
░░░    ░░ ░░    ░░ ░░ ░░░    ░░░
▒▒▒▒   ▒▒ ▒▒    ▒▒ ▒▒ ▒▒▒▒  ▒▒▒▒
▒▒ ▒▒  ▒▒ ▒▒    ▒▒ ▒▒ ▒▒ ▒▒▒▒ ▒▒
▓▓  ▓▓ ▓▓  ▓▓  ▓▓  ▓▓ ▓▓  ▓▓  ▓▓
██   ████   ████   ██ ██      ██]]

starter.setup({
	header = HEADER,

	-- Empty section name suppresses the label line. First letters stay unique so
	-- `evaluate_single` launches each item on one key.
	items = {
		{ name = "New file", action = "enew", section = "" },
		{ name = "Find files", action = "FzfLua files", section = "" },
		{ name = "Recent files", action = "FzfLua oldfiles", section = "" },
		{ name = "Browse (oil)", action = "Oil --float", section = "" },
		-- reveal=false: revealing the starter's ministarter:// pseudo-buffer
		-- triggers a change-cwd prompt.
		{ name = "Tree sidebar (neo-tree)", action = "Neotree reveal=false", section = "" },
		{ name = "Select Session", action = "lua MiniSessions.select()", section = "" },
		{ name = "Quit", action = "qall", section = "" },
	},

	content_hooks = {
		starter.gen_hook.adding_bullet(),
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
	-- vim.api.nvim_set_hl(0, "MiniStarterHeader", { fg = "#c4a7e7" })
	vim.api.nvim_set_hl(0, "MiniStarterHeader", { fg = "#9ccfd8" })
	vim.api.nvim_set_hl(0, "MiniStarterFooter", { link = "Comment" })
end

-- Loading a colorscheme clears all highlight groups, hence re-applying.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("jay_starter_hl", { clear = true }),
	callback = set_starter_hl,
})
set_starter_hl()
