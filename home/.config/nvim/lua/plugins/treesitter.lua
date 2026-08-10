-- `main` branch API, not what most tutorials show: no `ensure_installed`, no
-- `highlight = { enable }` — install parsers and start highlighting yourself.

require("nvim-treesitter").setup()

local parsers = {
  "typescript",
  "tsx",
  "javascript", -- also .jsx
  "python",
  "go",
  "gomod",
  "lua",
  "markdown",
  "markdown_inline",
  "json", -- also jsonc
  "yaml",
  "toml",
  "html",
  "css",
  "bash",
  "dockerfile",
  "sql",
  "vim",
  "vimdoc",
  "query",
  "git_config",
  "gitcommit",
  "diff",
  "regex",
}

local installed = require("nvim-treesitter.config").get_installed("parsers")
local missing = vim.tbl_filter(function(lang)
  return not vim.tbl_contains(installed, lang)
end, parsers)

if #missing > 0 then
  require("nvim-treesitter").install(missing)
end

-- Highlighting is opt-in per buffer on `main`.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("jay_treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not (lang and pcall(vim.treesitter.start, ev.buf, lang)) then
      return
    end
    -- Only where an `indents` query exists: without one the indentexpr returns
    -- 0 for every line, clobbering Neovim's built-in indent script.
    local ok, query = pcall(vim.treesitter.query.get, lang, "indents")
    if ok and query then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Sticky scroll.
require("treesitter-context").setup({
  max_lines = 3,
  multiline_threshold = 1,
})
