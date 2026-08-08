-- Editor behaviour. These are plain Neovim settings -- no plugin involved.
-- `:h 'optionname'` explains any of them in detail.

local o = vim.opt

-- Line numbers ---------------------------------------------------------------
o.number = true
o.relativenumber = true
o.signcolumn = "yes" -- always reserve the gutter, or text jumps sideways when
-- a git sign or error icon appears

-- Indentation ----------------------------------------------------------------
-- Fallbacks only; real projects get indentation from the formatter on save.
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true

-- Search ---------------------------------------------------------------------
o.ignorecase = true
o.smartcase = true -- ...unless you type a capital, then match case exactly
o.inccommand = "split" -- live preview of :substitute results as you type it

-- Splits ---------------------------------------------------------------------
o.splitright = true -- new vertical splits open to the right, not the left
o.splitbelow = true -- new horizontal splits open below

-- Persistence ----------------------------------------------------------------
o.undofile = true -- undo history survives closing the file
o.swapfile = false -- undofile covers the real recovery case

-- Appearance -----------------------------------------------------------------
o.termguicolors = true
o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.winborder = "rounded" -- borders on ALL floating windows; native since 0.11

-- Timing ---------------------------------------------------------------------
o.updatetime = 200 -- how long before CursorHold fires (gitsigns blame, etc.)
o.timeoutlen = 400 -- how long which-key waits before showing the hint popup

-- System integration ---------------------------------------------------------
o.clipboard = "unnamedplus" -- y and p use the macOS system clipboard
o.mouse = "a"
o.confirm = true -- :q on an unsaved buffer asks instead of erroring

-- Completion -----------------------------------------------------------------
o.completeopt = "menu,menuone,noselect" -- never auto-pick an item
o.pumheight = 10

-- Treesitter-based folding, but everything starts unfolded (foldlevel 99).
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99
o.foldtext = ""
