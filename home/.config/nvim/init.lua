-- A hand-rolled Neovim config. No framework.
--
-- Read in this order:
--   core/options.lua      how the editor behaves
--   core/keymaps.lua      what the keys do
--   core/diagnostics.lua  how errors are shown
--   core/autocmds.lua     things that happen automatically
--   plugins/init.lua      the plugin manifest (one list, one place)
--   lsp.lua               language servers
--
-- Plugins are managed by vim.pack, which ships with Neovim 0.12. There is no
-- plugin manager to install or bootstrap. `:h vim.pack` documents it.

-- Leader must be set before any keymap is defined, or the mappings bind to the
-- old leader and silently do nothing.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("core.options")
require("core.diagnostics")
require("core.autocmds")

require("plugins") -- installs + configures everything external
require("lsp") -- language servers (needs mason from plugins/)

require("core.keymaps") -- last: some maps reference plugin commands
