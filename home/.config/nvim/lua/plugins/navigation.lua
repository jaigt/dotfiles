-- fzf-lua wraps the Homebrew fzf binary and uses fd for file listing.
require("fzf-lua").setup({
	"telescope",
	winopts = {
		height = 0.85,
		width = 0.85,
		preview = {
			layout = "flex",
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

-- Routes vim.ui.select (pick-a-code-action, pick-a-definition) through fzf
-- instead of a numbered list at the bottom of the screen.
require("fzf-lua").register_ui_select()

-- oil: a directory as an editable buffer; `:w` applies the edits.
require("oil").setup({
	default_file_explorer = true, -- takes over netrw, including `nvim .`
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	view_options = {
		show_hidden = true,
	},
	keymaps = {
		["q"] = "actions.close",
		["<Esc>"] = "actions.close",
	},
	float = {
		override = function(conf)
			local buf = vim.api.nvim_get_current_buf()
			local lines = vim.api.nvim_buf_line_count(buf)
			conf.width = math.max(60, math.min(conf.width, 110))
			conf.height = math.max(8, math.min(lines + 1, 22))
			conf.row = 1
			conf.col = 2
			return conf
		end,
	},
})
vim.api.nvim_create_autocmd("User", {
	pattern = "OilEnter",
	callback = function(args)
		if vim.api.nvim_get_current_buf() == args.data.buf then
			require("oil").open_preview()
		end
	end,
})

require("neo-tree").setup({
	filesystem = {
		hijack_netrw_behavior = "disabled",
		bind_to_cwd = false,
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
