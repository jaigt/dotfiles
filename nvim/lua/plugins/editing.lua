require("conform").setup({
	formatters_by_ft = {
		-- prettierd is a daemon; it keeps prettier warm between saves.
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

		-- ruff keeps these separate: sort imports, then format.
		python = { "ruff_organize_imports", "ruff_format" },

		lua = { "stylua" },
		sh = { "shfmt" },
		bash = { "shfmt" },
	},

	format_on_save = function(bufnr)
		-- :FormatDisable — for repos with no formatter config, where prettier's
		-- defaults would rewrite every file.
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
		vim.b.disable_autoformat = true
	else
		vim.g.disable_autoformat = true
	end
end, { desc = "Turn off format-on-save (! = this buffer only)", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, { desc = "Turn format-on-save back on" })

require("mini.pairs").setup()

-- Remapped off the default `s` prefix, which shadows native `s` and `S`.
require("mini.surround").setup({
	mappings = {
		add = "gsa",
		delete = "gsd",
		replace = "gsr",
		find = "gsf",
		find_left = "gsF",
		highlight = "gsh",
		update_n_lines = "gsn",
	},
})

require("nvim-ts-autotag").setup()

-- Native `gc` picks comment syntax per filetype, so it emits `//` inside JSX,
-- which renders as literal text. ts-comments picks off the syntax tree.
require("ts-comments").setup()

-- Without this lua_ls treats `vim` as an undefined global.
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})
