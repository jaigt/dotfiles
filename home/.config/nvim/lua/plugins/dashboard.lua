-- The dashboard shown when nvim opens with no file.

local starter = require("mini.starter")

local HEADER = [[
░░░    ░░ ░░    ░░ ░░ ░░░    ░░░
▒▒▒▒   ▒▒ ▒▒    ▒▒ ▒▒ ▒▒▒▒  ▒▒▒▒
▒▒ ▒▒  ▒▒ ▒▒    ▒▒ ▒▒ ▒▒ ▒▒▒▒ ▒▒
▓▓  ▓▓ ▓▓  ▓▓  ▓▓  ▓▓ ▓▓  ▓▓  ▓▓
██   ████   ████   ██ ██      ██]]

starter.setup({
	header = HEADER,

	-- The empty section name suppresses the section label line. First letters
	-- are kept unique so with `evaluate_single` each item launches on one key.
	items = {
		{ name = "New file", action = "enew", section = "" },
		{ name = "Find files", action = "FzfLua files", section = "" },
		{ name = "Recent files", action = "FzfLua oldfiles", section = "" },
		{ name = "Browse (oil)", action = "Oil", section = "" },
		-- reveal=false: follow_current_file implies reveal, and revealing the
		-- starter's pseudo-buffer (ministarter://1) triggers a change-cwd prompt.
		{ name = "Tree sidebar (neo-tree)", action = "Neotree reveal=false", section = "" },
		{ name = "Select Session", action = "lua MiniSessions.select()", section = "" },
		{ name = "Quit", action = "qall", section = "" },
	},

	content_hooks = {
		starter.gen_hook.adding_bullet(),
		starter.gen_hook.aligning("center", "center"),
	},

	footer = function()
		-- `info = false` matters: the default gathers version data for every
		-- plugin, three git subprocesses each, paid again on every refresh. The
		-- count alone comes from the lockfile.
		local n = #(vim.pack.get(nil, { info = false }) or {})
		return ("%d plugins · nvim %s"):format(n, tostring(vim.version()))
	end,

	evaluate_single = true,
})

local function set_starter_hl()
	vim.api.nvim_set_hl(0, "MiniStarterHeader", { fg = "#c4a7e7" }) -- Rosé Pine iris
	vim.api.nvim_set_hl(0, "MiniStarterFooter", { link = "Comment" })
end

-- Loading a colorscheme clears all highlight groups, so re-apply on every
-- ColorScheme or the header reverts to default.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("jay_starter_hl", { clear = true }),
	callback = set_starter_hl,
})
set_starter_hl()
