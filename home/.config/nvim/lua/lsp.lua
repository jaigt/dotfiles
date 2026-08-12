-- nvim-lspconfig no longer wraps anything: it ships an `lsp/<name>.lua` data
-- file per server and `vim.lsp.enable()` picks it up. Any
-- `require('lspconfig').xxx.setup{}` you find online is pre-0.11 material.

require("mason").setup({
  ui = { border = "rounded" },
})

-- Servers installed via :Mason are enabled automatically (automatic_enable),
-- so a new one needs no entry here — this list only pins what a fresh
-- machine bootstraps.
require("mason-lspconfig").setup({
  ensure_installed = {
    "vtsls", -- TypeScript/TSX
    "eslint", -- also the linter, hence no separate one
    "basedpyright", -- Python types
    "ruff", -- Python lint + format
    "marksman", -- markdown
    "tailwindcss",
    "lua_ls", -- for editing this config
    "jsonls",
    "yamlls",
    "bashls",
    "html",
    "cssls",
  },
})

-- Non-LSP tools are outside mason-lspconfig's scope, hence the registry API.
-- refresh() hits the network, so it only runs when something is missing.
local tools = { "prettierd", "stylua", "shfmt" }
local registry = require("mason-registry")
local missing = vim.tbl_filter(function(name)
  return not registry.is_installed(name)
end, tools)
if #missing > 0 then
  registry.refresh(function()
    for _, name in ipairs(missing) do
      local ok, pkg = pcall(registry.get_package, name)
      if ok then
        vim.notify("Installing " .. name, vim.log.levels.INFO)
        pkg:install()
      end
    end
  end)
end

-- `vim.lsp.config` merges into nvim-lspconfig's defaults, so state only diffs.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      -- The default "recommended" flags every unannotated call in a real
      -- codebase. "standard" is plain pyright: real type errors only.
      analysis = { typeCheckingMode = "standard" },
    },
  },
})

vim.lsp.config("vtsls", {
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "literals" },
        variableTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
      },
    },
  },
})

-- K, gd, grn, gra, grr, gri, gO and <C-s> are native defaults — only the gaps
-- are bound here, on LspAttach so they exist only where a server attached.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("jay_lsp_attach", { clear = true }),
  callback = function(ev)
    local function map(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
    end

    map("gd", require("fzf-lua").lsp_definitions, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("gy", require("fzf-lua").lsp_typedefs, "Goto type definition")
    map("<leader>cs", require("fzf-lua").lsp_document_symbols, "Document symbols")
    map("<leader>cS", require("fzf-lua").lsp_live_workspace_symbols, "Workspace symbols")

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})
