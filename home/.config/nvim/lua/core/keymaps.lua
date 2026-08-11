local map = vim.keymap.set
local fzf = require("fzf-lua")
local sessions = require("mini.sessions")

-- Basics ----------------------------------------------------------------------
map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down (visual line)" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up (visual line)" })

map("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Prev search result" })

map("x", "<", "<gv", { desc = "Outdent" })
map("x", ">", ">gv", { desc = "Indent" })

map("x", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("x", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Windows ---------------------------------------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<leader>-", "<C-w>s", { desc = "Split below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split right" })

-- Buffers ---------------------------------------------------------------------
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<leader>,", fzf.buffers, { desc = "Switch buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers" })
map("n", "<leader>b[", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer left" })
map("n", "<leader>b]", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer right" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin buffer" })
for i = 1, 9 do
	map("n", "<leader>" .. i, function()
		require("bufferline").go_to(i, true)
	end, { desc = "Go to buffer " .. i })
end

-- Find ------------------------------------------------------------------------
map("n", "<leader><space>", fzf.files, { desc = "Find files" })
map("n", "<leader>ff", fzf.files, { desc = "Find files" })
map("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fg", fzf.git_files, { desc = "Find files (git-tracked)" })

-- Search ----------------------------------------------------------------------
map("n", "<leader>/", fzf.live_grep, { desc = "Grep project" })
map("n", "<leader>sg", fzf.live_grep, { desc = "Grep project" })
map("n", "<leader>sw", fzf.grep_cword, { desc = "Grep word under cursor" })
map("x", "<leader>sw", fzf.grep_visual, { desc = "Grep selection" })
map("n", "<leader>sb", fzf.lgrep_curbuf, { desc = "Grep current buffer" })
map("n", "<leader>sh", fzf.helptags, { desc = "Search help" })
map("n", "<leader>sk", fzf.keymaps, { desc = "Search keymaps" })
map("n", "<leader>sr", fzf.resume, { desc = "Resume last picker" })

-- Files -----------------------------------------------------------------------
map("n", "-", "<cmd>Oil --float<cr>", { desc = "File browser (Oil)" })
map("n", "<leader>e", function()
	require("oil").open_float()
end, { desc = "File browser (Oil)" })
map("n", "<leader>E", "<cmd>Neotree toggle<cr>", { desc = "File tree (neo-tree)" })

-- Terminal --------------------------------------------------------------------
local term_buf = nil
local termToggle = function()
	if vim.bo.buftype == "terminal" then
		vim.cmd("hide")
		return
	end
	if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
		vim.cmd("botright 15split")
		vim.api.nvim_win_set_buf(0, term_buf)
	else
		vim.cmd("botright 15split | term")
		term_buf = vim.api.nvim_get_current_buf()
		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(term_buf) then
				vim.api.nvim_buf_set_name(term_buf, "Terminal")
			end
		end, 50)
	end
	vim.cmd("startinsert")
end

map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map({ "n", "t" }, "<C-\\>", termToggle, { desc = "Toggle terminal" })
map("n", "<leader>t", termToggle, { desc = "Toggle terminal" })

-- Diagnostics -----------------------------------------------------------------
map("n", "<leader>xx", fzf.diagnostics_document, { desc = "Diagnostics (file)" })
map("n", "<leader>xX", fzf.diagnostics_workspace, { desc = "Diagnostics (project)" })
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics (float)" })

-- Code ------------------------------------------------------------------------
-- K, grn, gra and grr are native defaults; these are the extras.
map({ "n", "x" }, "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

-- Git -------------------------------------------------------------------------
local gs = require("gitsigns")
map("n", "]h", function()
	gs.nav_hunk("next")
end, { desc = "Next git hunk" })
map("n", "[h", function()
	gs.nav_hunk("prev")
end, { desc = "Previous git hunk" })
map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
map("x", "<leader>gs", function()
	gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage selected lines" })
map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
map("n", "<leader>gb", function()
	gs.blame_line({ full = true })
end, { desc = "Blame line (full)" })
map("n", "<leader>gd", "<cmd>CodeDiff file HEAD<cr>", { desc = "Diff file against HEAD (codediff)" })
map("n", "<leader>gS", fzf.git_status, { desc = "Git status" })
map("n", "<leader>gl", fzf.git_commits, { desc = "Git log" })
map("n", "<leader>gD", "<cmd>CodeDiff<cr>", { desc = "Review working tree (codediff)" })
map("n", "<leader>gc", function()
	-- `main...` is merge-base/PR-style; a bare rev diffs head-on.
	vim.ui.input({ prompt = "CodeDiff against: ", default = "main..." }, function(rev)
		if rev and rev ~= "" then
			vim.cmd("CodeDiff " .. rev)
		end
	end)
end, { desc = "Diff against revision (codediff)" })

-- Toggles ---------------------------------------------------------------------
map("n", "<leader>uw", function()
	vim.opt_local.wrap = not vim.opt_local.wrap:get()
end, { desc = "Toggle wrap" })

map("n", "<leader>uh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

map("n", "<leader>ub", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline git blame" })

map("n", "<leader>ud", function()
	local cfg = vim.diagnostic.config()
	if cfg.virtual_lines then
		vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
	else
		vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })
	end
end, { desc = "Toggle diagnostic style" })

-- Quit & sessions --------------------------------------------------------------
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })

-- create new session w current windows
-- switch to session from list
--  -- if no sessions graceful error
--  -- save current session as a session before switching?
-- delete session from list
-- -- if no session graceful error
-- restart and keep session

map("n", "<leader>qs", function()
	sessions.select()
end, { desc = "Switch to a session" })

map("n", "<leader>qr", function()
	sessions.restart()
end, { desc = "Restart Neovim w/ Session Restored" })

map("n", "<leader>qw", function()
	local input = vim.fn.input("Enter session name: ")
	if input and input ~= "" then
		sessions.write(input)
		print("\nCreated new session: " .. input)
	else
		print("\nSession save cancelled.")
	end
end, { desc = "Save this session" })

map("n", "<leader>qd", function()
	require("mini.sessions").select("delete")
	vim.cmd("redraw")
end, { desc = "Select session to delete" })

-- Plugin management -----------------------------------------------------------
map("n", "<leader>pu", function()
	vim.pack.update()
end, { desc = "Update plugins" })
map("n", "<leader>pl", function()
	vim.pack.update(nil, { offline = true })
end, { desc = "List installed plugins" })
map("n", "<leader>pm", "<cmd>Mason<cr>", { desc = "Mason (language servers)" })
