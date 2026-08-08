-- The plugin manifest.
--
-- vim.pack ships with Neovim 0.12 -- there is nothing to bootstrap. On first
-- launch it git-clones everything below into
-- `stdpath('data')/site/pack/core/opt/` and writes `nvim-pack-lock.json` next
-- to this config, pinning exact revisions. Commit that lockfile.
--
--   :lua vim.pack.update()          update everything (opens a reviewable diff;
--                                   :w to accept, :q to discard)
--   :lua vim.pack.update(nil, { offline = true })   list what's installed
--   :lua vim.pack.del({ 'name' })   remove one

local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	-- Appearance --------------------------------------------------------------
	gh("rebelot/kanagawa.nvim"), -- kept for the flip-back; see colorscheme.lua
	-- `name` is required: the repo is rose-pine/neovim, so without it vim.pack
	-- would clone into a directory called `neovim` and `require("rose-pine")`
	-- would fail.
	{ src = gh("rose-pine/neovim"), name = "rose-pine" }, -- the system theme; see colorscheme.lua
	-- Only ever loaded on Linux, where matugen.lua renders the Noctalia palette
	-- through it. Declared here rather than in home-linux's colorscheme.lua so
	-- both machines produce the same lockfile -- when the plugin sets differ,
	-- whichever box last ran vim.pack.update() drops the other's entries.
	gh("RRethy/base16-nvim"),
	gh("nvim-mini/mini.icons"), -- file-type icons for the picker + statusline
	gh("nvim-lualine/lualine.nvim"), -- statusline
	gh("nvim-mini/mini.starter"), -- the dashboard on an empty start
	gh("akinsho/bufferline.nvim"), -- open buffers along the top

	-- Language understanding ---------------------------------------------------
	-- `main` is the current rewrite of nvim-treesitter. The old `master` branch
	-- is frozen. They have different APIs -- most blog posts you find online are
	-- about `master`, so check the branch before copying anything.
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	gh("nvim-treesitter/nvim-treesitter-context"), -- sticky scroll

	-- Completion ---------------------------------------------------------------
	-- Pinned to the v1 tag range so vim.pack fetches a release, which ships a
	-- prebuilt fuzzy-matcher binary. Tracking the branch instead would require a
	-- local Rust toolchain to compile it.
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1") },
	gh("rafamadriz/friendly-snippets"), -- the snippet library blink expands

	-- LSP ----------------------------------------------------------------------
	gh("neovim/nvim-lspconfig"), -- default settings for ~350 language servers
	gh("mason-org/mason.nvim"), -- downloads the language server binaries
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
	-- On first run it curls a prebuilt C diff library into its data dir; the
	-- lockfile rev pins which binary that is.
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
