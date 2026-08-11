local o = vim.opt

o.number = true
o.relativenumber = true
o.signcolumn = "yes" -- always reserved, or text jumps when a sign appears

-- Fallbacks only; real projects get indentation from the formatter on save.
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2

o.ignorecase = true
o.smartcase = true
o.inccommand = "split"

o.splitright = true
o.splitbelow = true

o.undofile = true
o.swapfile = false

o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.winborder = "rounded"
o.pumborder = "rounded"

o.updatetime = 200 -- CursorHold delay: gitsigns blame, etc.
o.timeoutlen = 400 -- which-key popup delay

o.clipboard = "unnamedplus"
o.mouse = "a"
o.confirm = true

o.completeopt = "menu,menuone,noselect,popup,fuzzy"
o.pumheight = 10

-- Treesitter folding, everything unfolded to start.
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldtext = ""
