-- Things that happen automatically. `:h autocmd` for the general idea.

local function augroup(name)
  return vim.api.nvim_create_augroup("jay_" .. name, { clear = true })
end

-- Briefly highlight text you just yanked, so you can see what got copied.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Return to the line you were on when you last had this file open.
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

-- Create missing parent directories when you save to a path that doesn't exist
-- yet. Without this, `:e src/new/thing.ts` fails at write time with E212.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("mkdir"),
  callback = function(ev)
    if ev.match:match("^%w%w+://") then
      return -- a URL-ish buffer (oil://, fugitive://) -- not a real path
    end
    vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ":p:h"), "p")
  end,
})

-- Soft-wrap and spell-check prose.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- wrap at word boundaries, not mid-word
    vim.opt_local.spell = true
  end,
})

-- Close throwaway windows (help, man pages, quickfix) with plain `q`.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("quick_close"),
  pattern = { "help", "man", "qf", "checkhealth", "lspinfo", "startuptime" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})
