-- which-key reads each keymap's `desc`; one defined without it shows as a
-- blank row.
require("which-key").setup({
	preset = "helix",
	delay = 400,
})

require("which-key").add({
	-- <leader> prefixes, in the order the sections appear in core/keymaps.lua
	{ "<leader>b", group = "buffer" },
	{ "<leader>f", group = "find" },
	{ "<leader>s", group = "search" },
	{ "<leader>q", group = "sessions" },
	{ "<leader>g", group = "git" },
	{ "<leader>x", group = "diagnostics" },
	{ "<leader>c", group = "code" },
	{ "<leader>u", group = "toggle/ui" },
	{ "<leader>p", group = "plugins" },
	{ "<leader>o", group = "obsidian" }, -- maps live in plugins/obsidian.lua

	-- non-leader prefixes
	{ "g", group = "goto" },
	{ "gs", group = "surround", mode = { "n", "x" } },
	{ "]", group = "next" },
	{ "[", group = "previous" },
})
