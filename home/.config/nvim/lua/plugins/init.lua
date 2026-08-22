local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	-- Colorschemes; others come session-only from fzf's awesome_colorschemes.
	-- rose-pine is the macOS default, kanagawa + base16 are used on Linux.
	{ src = gh("rose-pine/neovim"), name = "rose-pine" },
	gh("rebelot/kanagawa.nvim"),
	gh("RRethy/base16-nvim"),

	-- Dashboard
	gh("nvim-mini/mini.starter"), -- dashboard

	-- UI
	gh("nvim-mini/mini.icons"), -- file-type icons for the picker + statusline
	gh("nvim-lualine/lualine.nvim"), -- statusline

	-- Language (Treesitter, Completion, LSP)
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	gh("nvim-treesitter/nvim-treesitter-context"),

	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1") },
	gh("rafamadriz/friendly-snippets"),

	gh("neovim/nvim-lspconfig"), -- default settings for ~350 language servers
	gh("mason-org/mason.nvim"), -- downloads the language server binaries
	gh("mason-org/mason-lspconfig.nvim"), -- auto-enables whatever mason installs
	gh("folke/lazydev.nvim"), -- makes lua_ls understand the Neovim API

	-- Editing
	gh("stevearc/conform.nvim"), -- format on save
	gh("nvim-mini/mini.pairs"), -- auto-close brackets and quotes
	gh("nvim-mini/mini.surround"), -- wrap a selection in brackets/quotes/tags
	gh("windwp/nvim-ts-autotag"), -- auto-close JSX/HTML tags
	gh("folke/ts-comments.nvim"), -- makes `gc` emit `{/* */}` inside JSX

	-- Navigation
	gh("ibhagwan/fzf-lua"), -- fuzzy finder; uses the Homebrew fzf + fd
	gh("stevearc/oil.nvim"), -- edit the filesystem as a buffer
	{ src = gh("nvim-neo-tree/neo-tree.nvim"), version = vim.version.range("3") }, -- sidebar tree-view
	gh("nvim-lua/plenary.nvim"), -- dependency of neo-tree
	gh("MunifTanjim/nui.nvim"), -- dependency of neo-tree

	-- Git
	gh("lewis6991/gitsigns.nvim"), -- gutter hunks, stage/reset a hunk, blame
	-- Curls a prebuilt C diff library on first run; the lockfile rev pins it.
	gh("esmuellert/codediff.nvim"), -- VSCode-style diff review UI + mergetool

	-- Etc.
	gh("folke/which-key.nvim"), -- press a prefix, see what's available
	gh("nvim-mini/mini.sessions"),

	-- Obsidian
	gh("obsidian-nvim/obsidian.nvim"),
	gh("MeanderingProgrammer/render-markdown.nvim"),
})

require("plugins.dev") -- local plugins in development (runtimepath, not vim.pack)
require("plugins.colorscheme")
require("plugins.dashboard")
require("plugins.ui")
require("plugins.language")
require("plugins.editing")
require("plugins.navigation")
require("plugins.git")
require("plugins.etc")
require("plugins.obsidian")
