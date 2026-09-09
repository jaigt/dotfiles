-- Completions
require("blink.cmp").setup({
	keymap = {
		preset = "default",
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = {
			function()
				local s = require("copilot.suggestion")
				if s.is_visible() then
					s.accept()
					return true
				end
			end,
			"snippet_forward",
			"fallback",
		},
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 200 },
		ghost_text = { enabled = false },
		menu = {
			draw = {
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
					{ "source_name" },
				},
			},
		},
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},

	signature = { enabled = true },

	fuzzy = {
		-- Prebuilt Rust matcher, falling back to pure-Lua rather than not starting.
		implementation = "prefer_rust_with_warning",
	},
})

require("copilot").setup({
	panel = { enabled = false },
	suggestion = {
		enabled = true,
		auto_trigger = true,
		keymap = { accept = false, next = false, prev = false, dismiss = false },
	},
	filetypes = { markdown = false, gitcommit = false, ["."] = false },
})

vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuOpen",
	callback = function()
		vim.b.copilot_suggestion_hidden = true
	end,
})
vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuClose",
	callback = function()
		vim.b.copilot_suggestion_hidden = false
	end,
})
