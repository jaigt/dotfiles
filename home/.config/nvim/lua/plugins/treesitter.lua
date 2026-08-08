-- NOTE: this is the `main` branch API, which is not what most tutorials show.
-- On `main` there is no `ensure_installed` and no `highlight = { enable }`;
-- you install parsers imperatively and start highlighting yourself.

require("nvim-treesitter").setup()

local parsers = {
  "typescript",
  "tsx",
  "javascript", -- also handles .jsx; there is no separate jsx parser
  "python",
  "go",
  "gomod",
  "lua",
  "markdown",
  "markdown_inline",
  "json", -- also covers jsonc; there is no separate jsonc parser
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

-- Install anything missing. Runs async on first launch.
local installed = require("nvim-treesitter.config").get_installed("parsers")
local missing = vim.tbl_filter(function(lang)
  return not vim.tbl_contains(installed, lang)
end, parsers)

if #missing > 0 then
  require("nvim-treesitter").install(missing)
end

-- On `main`, highlighting is opt-in per buffer. This turns it on for any
-- filetype that has a parser available, and stays quiet for those that don't.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("jay_treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not (lang and pcall(vim.treesitter.start, ev.buf, lang)) then
      return
    end
    -- Tree-aware indentation, but only where an `indents` query exists. Without
    -- one nvim-treesitter's indentexpr returns 0 for every line -- no autoindent
    -- at all -- and setting it would clobber Neovim's built-in indent script.
    local ok, query = pcall(vim.treesitter.query.get, lang, "indents")
    if ok and query then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Sticky scroll: the enclosing function/class signature pins to the top of the
-- window as you scroll past it.
require("treesitter-context").setup({
  max_lines = 3, -- don't let a deeply nested block eat the screen
  multiline_threshold = 1, -- collapse long signatures to one line
})
