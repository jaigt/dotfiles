-- Language servers.
--
-- On 0.11+ nvim-lspconfig no longer wraps anything -- it just ships a
-- `lsp/<name>.lua` data file per server, and `vim.lsp.enable()` picks those up
-- off the runtime path. There are no `require('lspconfig').xxx.setup{}` calls
-- any more; if you see those online, you're reading pre-0.11 material.

-- mason downloads the server binaries into `stdpath('data')/mason/bin` and puts
-- that on PATH, which is how the servers below get found.
require("mason").setup({
  ui = { border = "rounded" },
})

local servers = {
  "vtsls", -- TypeScript/TSX
  "eslint", -- also does the linting, which is why there's no separate linter
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
}

-- No Go here on purpose: no Go toolchain installed. To add it, `brew install
-- go`, `:MasonInstall gopls goimports`, then add "gopls" above and a `go` entry
-- to plugins/format.lua.

-- The mason package name doesn't always match the lspconfig server name.
local mason_packages = {
  lua_ls = "lua-language-server",
  jsonls = "json-lsp",
  yamlls = "yaml-language-server",
  bashls = "bash-language-server",
  html = "html-lsp",
  cssls = "css-lsp",
  tailwindcss = "tailwindcss-language-server",
  eslint = "eslint-lsp",
}

-- Formatters used by conform.nvim. Mason installs these the same way.
local tools = { "prettierd", "stylua", "shfmt" }

-- Install anything missing, once, in the background. Mason has no declarative
-- `ensure_installed` of its own, so this drives its registry API directly.
vim.api.nvim_create_autocmd("User", {
  pattern = "MasonToolsBootstrap",
  once = true,
  callback = function()
    local registry = require("mason-registry")
    registry.refresh(function()
      local wanted = vim.list_extend(
        vim.tbl_map(function(s)
          return mason_packages[s] or s
        end, servers),
        tools
      )
      for _, name in ipairs(wanted) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not pkg:is_installed() then
          vim.notify("Installing " .. name, vim.log.levels.INFO)
          pkg:install()
        end
      end
    end)
  end,
})
vim.schedule(function()
  vim.api.nvim_exec_autocmds("User", { pattern = "MasonToolsBootstrap" })
end)

-- Per-server tweaks. `vim.lsp.config` merges into whatever nvim-lspconfig
-- already defined, so we only state the differences.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      -- lazydev (see plugins/editing.lua) supplies the Neovim API types.
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      -- Default is "recommended", which flags every unannotated call in real
      -- codebases. "standard" = plain pyright's strictness: real type errors
      -- only. Ruff covers lint.
      analysis = { typeCheckingMode = "standard" },
    },
  },
})

vim.lsp.config("vtsls", {
  settings = {
    typescript = {
      -- Inlay hints: native since 0.10, but shipped off.
      inlayHints = {
        parameterNames = { enabled = "literals" },
        variableTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
      },
    },
  },
})

vim.lsp.enable(servers)

-- LSP keymaps -----------------------------------------------------------------
-- Most of what you want is ALREADY bound by default in 0.11+. The native ones:
--
--   K      hover docs           grn    rename symbol
--   gd     go to definition     gra    code action
--   grr    find references      gri    go to implementation
--   gO     document symbols     <C-s>  signature help (insert mode)
--
-- Only the gaps get bound here, on LspAttach so they exist solely in buffers
-- that actually have a language server.
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

    -- Turn inlay hints on if this server provides them.
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})
