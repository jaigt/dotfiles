-- Getting around: fuzzy finder and file explorers.

-- fzf-lua ---------------------------------------------------------------------
-- Wraps the Homebrew fzf binary, and uses fd for file listing.
require("fzf-lua").setup({
	"default-title",
	winopts = {
		height = 0.85,
		width = 0.85,
		preview = {
			layout = "flex", -- preview on the right in a wide window, below in a narrow one
			scrollbar = false,
		},
	},
	files = {
		formatter = "path.filename_first",
		fd_opts = "--hidden --color=never --type f --type l --exclude .git --exclude .jj",
	},
	grep = {
		rg_opts = "--hidden -g '!.git' --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
	},
})

-- Route vim.ui.select through fzf. That's the menu Neovim shows for "pick a
-- code action", "pick a definition when there are several" -- without this it's
-- a numbered list at the bottom of the screen.
require("fzf-lua").register_ui_select()

-- oil.nvim --------------------------------------------------------------------
-- A directory opens as an ordinary, editable buffer; `:w` applies the edits.
-- Bound to `-` (see keymaps.lua).
require("oil").setup({
	default_file_explorer = true, -- take over from netrw, including for `nvim .`
	view_options = {
		show_hidden = true,
	},
	keymaps = {
		["q"] = "actions.close",
	},
})

-- neo-tree.nvim ---------------------------------------------------------------
-- Browse the filesystem as a tree in the sidebar.
require("neo-tree").setup({
	filesystem = {
		hijack_netrw_behavior = "disabled",
		follow_current_file = { enabled = true },
		filtered_items = {
			visible = true,
			hide_dotfiles = false,
			hide_gitignored = true,
		},
	},
	window = {
		width = 30,
		auto_expand_width = true,
	},
	close_if_last_window = true,
})
