-- vim.pack writes nvim-pack-lock.json next to this file. Commit it.
--
--   :lua vim.pack.update()          update all (reviewable diff; :w / :q)
--   :lua vim.pack.del({ 'name' })   remove one

local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	-- Appearance --------------------------------------------------------------
	gh("rebelot/kanagawa.nvim"), -- kept for the flip-back; see colorscheme.lua
	-- `name` required: the repo is rose-pine/neovim, so vim.pack would otherwise
	-- clone into `neovim` and require("rose-pine") would fail.
	{ src = gh("rose-pine/neovim"), name = "rose-pine" }, -- the system theme; see colorscheme.lua
	-- Linux-only at runtime, but declared here so both machines produce the same
	-- lockfile — otherwise whichever box last ran update() drops the other's.
	gh("RRethy/base16-nvim"),
	gh("nvim-mini/mini.icons"), -- file-type icons for the picker + statusline
	gh("nvim-lualine/lualine.nvim"), -- statusline
	gh("nvim-mini/mini.starter"), -- the dashboard on an empty start

	-- Language understanding ---------------------------------------------------
	-- `main` and the frozen `master` have different APIs, and most material
	-- online is about `master`. Check the branch before copying anything.
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	gh("nvim-treesitter/nvim-treesitter-context"), -- sticky scroll

	-- Completion ---------------------------------------------------------------
	-- Tag range, not branch: releases ship a prebuilt fuzzy-matcher binary;
	-- tracking the branch would need a local Rust toolchain.
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1") },
	gh("rafamadriz/friendly-snippets"), -- the snippet library blink expands

	-- LSP ----------------------------------------------------------------------
	gh("neovim/nvim-lspconfig"), -- default settings for ~350 language servers
	gh("mason-org/mason.nvim"), -- downloads the language server binaries
	gh("mason-org/mason-lspconfig.nvim"), -- auto-enables whatever mason installs
	gh("folke/lazydev.nvim"), -- makes lua_ls understand the Neovim API

	-- Editing ------------------------------------------------------------------
	gh("stevearc/conform.nvim"), -- format on save
	gh("nvim-mini/mini.pairs"), -- auto-close brackets and quotes
	gh("nvim-mini/mini.surround"), -- wrap a selection in brackets/quotes/tags
	gh("windwp/nvim-ts-autotag"), -- auto-close JSX/HTML tags
	gh("folke/ts-comments.nvim"), -- makes `gc` emit `{/* */}` inside JSX

	-- Navigation ---------------------------------------------------------------
	gh("ibhagwan/fzf-lua"), -- fuzzy finder; uses the Homebrew fzf + fd
	gh("stevearc/oil.nvim"), -- edit the filesystem as a buffer
	{ src = gh("nvim-neo-tree/neo-tree.nvim"), version = vim.version.range("3") }, -- sidebar tree-view
	gh("nvim-lua/plenary.nvim"), -- dependency of neo-tree
	gh("MunifTanjim/nui.nvim"), -- dependency of neo-tree

	-- Git ----------------------------------------------------------------------
	gh("lewis6991/gitsigns.nvim"), -- gutter hunks, stage/reset a hunk, blame
	-- Curls a prebuilt C diff library on first run; the lockfile rev pins it.
	gh("esmuellert/codediff.nvim"), -- VSCode-style diff review UI + mergetool

	-- Etc. --------------------------------------------------------------------
	gh("folke/which-key.nvim"), -- press a prefix, see what's available
	gh("nvim-mini/mini.sessions"),
})

require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.completion")
require("plugins.format")
require("plugins.navigation")
require("plugins.git")
require("plugins.ui")
require("plugins.dashboard")
require("plugins.editing")
