local function augroup(name)
	return vim.api.nvim_create_augroup("jay_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_location"),
	callback = function(ev)
		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(ev.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- mkdir -p on write: without this, `:e src/new/thing.ts` fails with E212.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("mkdir"),
	callback = function(ev)
		if ev.match:match("^%w%w+://") then
			return -- oil://, fugitive:// etc, not a real path
		end
		vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ":p:h"), "p")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("prose"),
	pattern = { "markdown", "gitcommit", "text" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("quick_close"),
	pattern = { "help", "man", "qf", "checkhealth", "lspinfo", "startuptime" },
	callback = function(ev)
		vim.bo[ev.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
	end,
})

vim.api.nvim_create_autocmd("BufDelete", {
	group = augroup("dashboard"),
	callback = function()
		local bufs = vim.tbl_filter(function(buf)
			return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
		end, vim.api.nvim_list_bufs())
		if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
			require("mini.starter").open()
		end
	end,
})
