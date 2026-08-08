-- How errors and warnings are displayed.
--
-- `virtual_lines` renders the full message on its own line underneath the
-- offending code, rather than truncating it at the screen edge the way
-- `virtual_text` does. Native since 0.11, off by default.

vim.diagnostic.config({
  -- Only expand the error under the cursor; every line at once pushes the code
  -- apart into ribbons.
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
  update_in_insert = false, -- don't flag errors mid-keystroke; it's just noise
  severity_sort = true, -- errors win the gutter over warnings on the same line

  float = {
    border = "rounded",
    source = true, -- say WHICH tool complained (eslint? vtsls? ruff?)
  },
})
