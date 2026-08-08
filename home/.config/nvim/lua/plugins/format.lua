-- Format on save. Where no formatter is configured for a filetype conform falls
-- back to the language server, and stays quiet if neither exists.

require("conform").setup({
  formatters_by_ft = {
    -- prettierd is a daemon: it keeps prettier warm between saves (~800ms to
    -- ~30ms on a TSX file).
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },

    -- Two steps: sort imports, then format -- ruff keeps these separate.
    python = { "ruff_organize_imports", "ruff_format" },

    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },

  format_on_save = function(bufnr)
    -- Escape hatch for repos with no formatter config, where prettier's
    -- defaults would rewrite every file:  :FormatDisable  (! = this buffer)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return {
      timeout_ms = 3000,
      lsp_format = "fallback",
    }
  end,
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true -- this buffer only
  else
    vim.g.disable_autoformat = true -- everywhere, until you restart
  end
end, { desc = "Turn off format-on-save (! = this buffer only)", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = "Turn format-on-save back on" })
