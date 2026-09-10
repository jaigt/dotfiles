local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	-- colorscheme.lua
	{ src = gh("rose-pine/neovim"), name = "rose-pine" },
	gh("sainnhe/gruvbox-material"),
	gh("rebelot/kanagawa.nvim"),

	-- mini.lua
	gh("nvim-mini/mini.nvim"),

	-- ui.lua
	gh("nvim-lualine/lualine.nvim"),
	gh("j-hui/fidget.nvim"),

	-- treesitter.lua
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	gh("nvim-treesitter/nvim-treesitter-context"),

	-- cmp.lua
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1") },
	gh("rafamadriz/friendly-snippets"),
	gh("zbirenbaum/copilot.lua"),

	-- lsp.lua
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason.nvim"),
	gh("mason-org/mason-lspconfig.nvim"),

	-- code.lua
	gh("stevearc/conform.nvim"),
	gh("windwp/nvim-ts-autotag"),
	gh("folke/ts-comments.nvim"),
	gh("folke/lazydev.nvim"),

	-- files.lua
	gh("ibhagwan/fzf-lua"),
	gh("stevearc/oil.nvim"),
	{ src = gh("nvim-neo-tree/neo-tree.nvim"), version = vim.version.range("3") },
	gh("nvim-lua/plenary.nvim"),
	gh("MunifTanjim/nui.nvim"),

	-- git.lua
	gh("lewis6991/gitsigns.nvim"),
	gh("esmuellert/codediff.nvim"),

	-- obsidian.lua
	gh("epwalsh/obsidian.nvim"),
	gh("MeanderingProgrammer/render-markdown.nvim"),

	-- misc.lua
	gh("folke/which-key.nvim"),
})

require("plugins.dev")
require("plugins.colorscheme")
require("plugins.mini")
require("plugins.ui")
require("plugins.treesitter")
require("plugins.cmp")
require("plugins.code")
require("plugins.files")
require("plugins.git")
require("plugins.obsidian")
require("plugins.misc")
