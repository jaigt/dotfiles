require("mini.pairs").setup()

-- Remapped off the default `s` prefix, which shadows native `s` and `S`.
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

require("nvim-ts-autotag").setup()

-- Native `gc` picks comment syntax per filetype, so it emits `//` inside JSX,
-- which renders as literal text. ts-comments picks off the syntax tree.
require("ts-comments").setup()

-- Without this lua_ls treats `vim` as an undefined global.
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})
