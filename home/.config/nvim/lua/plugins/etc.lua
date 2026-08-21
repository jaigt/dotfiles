-- which-key reads each keymap's `desc`; one defined without it shows as a
-- blank row.
require("which-key").setup({
	preset = "helix",
	delay = 400,
})

require("which-key").add({
	{ "<leader>f", group = "find" },
	{ "<leader>s", group = "search" },
	{ "<leader>q", group = "quit & sessions" },
	{ "<leader>g", group = "git" },
	{ "<leader>c", group = "code" },
	{ "<leader>b", group = "buffer" },
	{ "<leader>u", group = "toggle/ui" },
	{ "<leader>p", group = "plugins" },
	{ "<leader>x", group = "diagnostics" },
	{ "g", group = "goto" },
	{ "gs", group = "surround", mode = { "n", "x" } },
	{ "]", group = "next" },
	{ "[", group = "previous" },
})

require("mini.sessions").setup({
	autoread = false,
	autowrite = true,
})
