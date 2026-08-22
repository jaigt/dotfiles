-- obsidian.nvim (community fork). The Obsidian app stays the primary client;
-- this is for capture and editing from the terminal. Completion, gd on links,
-- grn rename, and grr backlinks all come through its in-process LSP.
local vault = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault")

require("obsidian").setup({
	legacy_commands = false,
	workspaces = { { name = "vault", path = vault } },
	picker = { name = "fzf-lua" },

	-- The vault's frontmatter is `date` + `tags` from Templater; the plugin's
	-- managed frontmatter would inject `id`/`aliases` into every note on save.
	frontmatter = { enabled = false },

	-- Filename = the title as typed, matching app-created notes (the default
	-- generates zettel IDs like 1755800000-ABCD).
	note_id_func = function(title)
		if title and title ~= "" then
			return title
		end
		return os.date("%Y-%m-%d %H%M%S")
	end,

	-- `:Obsidian new` is quick capture: lands in Quick Notes with its template.
	notes_subdir = "Quick Notes",
	new_notes_location = "notes_subdir",
	note = { template = "Quick Note" },

	daily_notes = {
		folder = "Daily Notes",
		date_format = "YYYY-MM-DD",
		template = "Daily Note",
		default_tags = {},
		workdays_only = false,
	},

	-- Templater syntax (<% tp.* %>) doesn't run outside the app, so these are
	-- {{var}}-syntax twins of the app templates, kept out of the app's picker.
	templates = {
		folder = "Templates/nvim",
		date_format = "YYYY-MM-DD",
		time_format = "h:mm A",
		substitutions = {
			-- Heading for the note's own date. {{date}} is always today, which
			-- is wrong for `:Obsidian yesterday`; a daily note's id IS its date.
			daily_title = function(ctx)
				local util = require("obsidian.util")
				local id = ctx.partial_note and tostring(ctx.partial_note.id)
				local date = id and util.parse_date(id, "YYYY-MM-DD")
				local time = date and os.time(date) or os.time()
				return util.format_date(time, "dddd, MMMM D, YYYY")
			end,
			-- Class notes are named "COURSE - YYYY-MM-DD"; this is the COURSE part.
			class_name = function(ctx)
				local name = ctx.partial_note and ctx.partial_note:display_name() or ""
				return (name:gsub("%s*%-%s*%d%d%d%d%-%d%d%-%d%d$", ""))
			end,
		},
		customizations = {
			["Class Note"] = { notes_subdir = "Class Notes/Fall 2026" },
		},
	},

	attachments = { folder = "./Attachments" }, -- same as the app's setting

	ui = { enable = false }, -- render-markdown draws the buffer instead
})

require("render-markdown").setup({
	-- Render in every mode, insert included; anti_conceal alone reveals the
	-- raw text at the cursor (not the default unrender-in-insert behavior).
	render_modes = true,
	anti_conceal = { above = 0, below = 0 },
	-- Vault buffers only; delete this to restyle all markdown (READMEs etc).
	ignore = function(buf)
		return not vim.startswith(vim.api.nvim_buf_get_name(buf), vault)
	end,
	-- The vault's extra checkbox states, matching what the Minimal theme shows.
	checkbox = {
		custom = {
			partial = { raw = "[~]", rendered = "󰰱 ", highlight = "RenderMarkdownWarn" },
			important = { raw = "[!]", rendered = " ", highlight = "RenderMarkdownError" },
			forwarded = { raw = "[>]", rendered = " ", highlight = "RenderMarkdownInfo" },
		},
	},
})

-- marksman would double up gd/rename in vault buffers and doesn't know
-- Obsidian link resolution; keep it for markdown outside the vault only.
vim.lsp.config("marksman", {
	root_dir = function(bufnr, on_dir)
		local name = vim.api.nvim_buf_get_name(bufnr)
		if not vim.startswith(name, vault) then
			on_dir(vim.fs.root(bufnr, { ".marksman.toml", ".git" }) or vim.fs.dirname(name))
		end
	end,
})

-- In-buffer maps come with the plugin: <CR> smart action (follow link /
-- toggle checkbox), ]o and [o between links.
local map = vim.keymap.set
map("n", "<leader>oo", "<cmd>Obsidian quick_switch<cr>", { desc = "Find note" })
map("n", "<leader>os", "<cmd>Obsidian search<cr>", { desc = "Grep vault" })
map("n", "<leader>on", "<cmd>Obsidian new<cr>", { desc = "New quick note" })
map("n", "<leader>oN", "<cmd>Obsidian new_from_template<cr>", { desc = "New note from template" })
map("n", "<leader>oc", function()
	vim.ui.input({ prompt = "Class: " }, function(course)
		if not course or course == "" then
			return
		end
		-- One note per lecture: "COURSE - YYYY-MM-DD" unless a date was given.
		local title = course
		if not title:match("%d%d%d%d%-%d%d%-%d%d$") then
			title = title .. " - " .. os.date("%Y-%m-%d")
		end
		require("obsidian.actions").new_from_template(title, "Class Note", function(note)
			note:open({ sync = true })
		end)
	end)
end, { desc = "New class note" })
map("n", "<leader>ot", "<cmd>Obsidian today<cr>", { desc = "Today's daily note" })
map("n", "<leader>oy", "<cmd>Obsidian yesterday<cr>", { desc = "Yesterday's daily note" })
map("n", "<leader>od", "<cmd>Obsidian dailies<cr>", { desc = "Browse daily notes" })
map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", { desc = "Backlinks" })
map("n", "<leader>ol", "<cmd>Obsidian links<cr>", { desc = "Links in note" })
map("n", "<leader>or", "<cmd>Obsidian rename<cr>", { desc = "Rename note (updates links)" })
map("n", "<leader>oi", "<cmd>Obsidian paste_img<cr>", { desc = "Paste image from clipboard" })
map("n", "<leader>og", "<cmd>Obsidian tags<cr>", { desc = "Browse tags" })
map("n", "<leader>oO", "<cmd>Obsidian open<cr>", { desc = "Open in Obsidian app" })
map("n", "<leader>ou", "<cmd>RenderMarkdown buf_toggle<cr>", { desc = "Toggle markdown rendering" })
map("x", "<leader>oe", ":Obsidian extract_note<cr>", { desc = "Extract selection to new note" })
map("x", "<leader>ol", ":Obsidian link<cr>", { desc = "Link selection to existing note" })
