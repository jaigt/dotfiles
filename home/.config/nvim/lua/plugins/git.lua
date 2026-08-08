-- Git -- deliberately only the part a terminal can't do: in-buffer hunks,
-- staging one hunk out of five, and blame for the line under the cursor.
-- gitsigns owns the in-buffer side; codediff is the review UI (working-tree
-- explorer, branch compare, mergetool). Keymaps live in core/keymaps.lua.

require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },

  current_line_blame = true,
  current_line_blame_opts = {
    virt_text_pos = "eol",
    delay = 300,
    ignore_whitespace = true,
  },
  current_line_blame_formatter = "  <author>, <author_time:%R> · <summary>",
})

require("codediff").setup()
