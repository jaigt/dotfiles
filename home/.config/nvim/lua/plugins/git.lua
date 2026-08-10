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
