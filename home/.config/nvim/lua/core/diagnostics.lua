-- `virtual_lines` prints the full message under the code instead of truncating
-- it at the screen edge like `virtual_text`. Only for the cursor's line —
-- every line at once pushes the code apart into ribbons.

vim.diagnostic.config({
  virtual_lines = { current_line = true },

  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },

  underline = true,
  update_in_insert = false, -- mid-keystroke errors are noise
  severity_sort = true, -- errors win the gutter over warnings

  float = {
    border = "rounded",
    source = true, -- which tool complained
  },
})
