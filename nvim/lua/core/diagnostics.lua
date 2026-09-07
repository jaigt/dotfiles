vim.diagnostic.config({
	virtual_text = true,

	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	},

	underline = true,
	update_in_insert = false, -- mid-keystroke errors are noise
	severity_sort = true, -- errors win the gutter over warnings

	float = {
		border = "rounded",
		source = true, -- which tool complained
	},
})
