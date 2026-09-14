require("render-markdown").setup({
	-- Render in every mode, insert included; anti_conceal alone reveals the
	-- raw text at the cursor (not the default unrender-in-insert behavior).
	render_modes = true,
	anti_conceal = { above = 0, below = 0 },
})

vim.keymap.set("n", "<leader>um", "<cmd>RenderMarkdown buf_toggle<cr>", { desc = "Toggle markdown rendering" })
