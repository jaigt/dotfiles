-- Small editing conveniences.

require("mini.pairs").setup()

-- Remapped off the default `s`-prefixed mappings, which would shadow native `s`
-- (substitute character) and `S`.
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

-- Auto-close and auto-rename JSX/HTML tags.
require("nvim-ts-autotag").setup()

-- `gc` itself is native, but Neovim picks the comment syntax per *filetype*,
-- and a .tsx file contains two: `//` in the TypeScript, `{/* */}` inside the
-- JSX. Native `gc` emits `//` inside JSX, which renders as literal text on the
-- page. ts-comments picks the right one off the syntax tree.
require("ts-comments").setup()

-- Teaches lua_ls the Neovim API; without it `vim` is an undefined global.
require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})
