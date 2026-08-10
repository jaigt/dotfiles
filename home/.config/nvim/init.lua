-- Leader must be set before any keymap is defined, or mappings bind to the old
-- leader and silently do nothing.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("core.options")
require("core.diagnostics")
require("core.autocmds")

require("plugins") -- installs + configures everything external
require("lsp") -- language servers (needs mason from plugins/)

require("core.keymaps") -- last: some maps reference plugin commands
