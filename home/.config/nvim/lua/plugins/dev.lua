-- Local plugins under active development: raw runtimepath instead of vim.pack,
-- so the working tree runs as-is — no commit/update cycle. Guarded so machines
-- without the checkout are unaffected.
for _, dir in ipairs({
	"~/Workspace/zoil.nvim",
}) do
	dir = vim.fs.normalize(dir)
	if vim.uv.fs_stat(dir) then
		vim.opt.runtimepath:prepend(dir)
	end
end
