-- Statusline, icons, and the keymap hint popup.

require("mini.icons").setup()
-- Some plugins still ask for nvim-web-devicons by name. This makes mini.icons
-- answer to that name too, so we don't need to install a second icon plugin.
MiniIcons.mock_nvim_web_devicons()

-- which-key -------------------------------------------------------------------
-- Reads the `desc` field from every keymap, so a binding defined without a
-- desc shows up as a blank. That's why keymaps.lua sets desc on all of them.
require("which-key").setup({
	preset = "helix", -- side panel rather than a bottom strip
	delay = 400,
})

-- Group labels.
require("which-key").add({
	{ "<leader>f", group = "find" },
	{ "<leader>s", group = "search" },
	{ "<leader>q", group = "quit & sessions" },
	{ "<leader>g", group = "git" },
	{ "<leader>c", group = "code" },
	{ "<leader>b", group = "buffer" },
	{ "<leader>u", group = "toggle/ui" },
	{ "<leader>x", group = "diagnostics" },
	{ "g", group = "goto" },
	{ "gs", group = "surround", mode = { "n", "x" } },
	{ "]", group = "next" },
	{ "[", group = "previous" },
})

-- Breadcrumbs -----------------------------------------------------------------
-- "Class > method > block" for wherever the cursor is, off the treesitter tree.
local BREADCRUMB_NODES = {
	class_declaration = true,
	class_definition = true,
	function_declaration = true,
	function_definition = true,
	function_item = true,
	method_declaration = true,
	method_definition = true,
	arrow_function = true,
	variable_declarator = true,
	assignment = true,
}

local function breadcrumbs()
	-- Bail on very large files: this runs on every statusline redraw.
	if vim.api.nvim_buf_line_count(0) > 20000 then
		return ""
	end
	local ok, node = pcall(vim.treesitter.get_node)
	if not ok or not node then
		return ""
	end

	local parts = {}
	while node and #parts < 4 do
		if BREADCRUMB_NODES[node:type()] then
			local name = node:field("name")[1]
			if name then
				local got, text = pcall(vim.treesitter.get_node_text, name, 0)
				-- Skip anonymous and absurdly long names rather than blow out the line.
				if got and text and text ~= "" and #text < 30 and not text:find("\n") then
					table.insert(parts, 1, text)
				end
			end
		end
		node = node:parent()
	end

	return #parts > 0 and ("󰆧 " .. table.concat(parts, " › ")) or ""
end

-- lualine ---------------------------------------------------------------------
require("lualine").setup({
	options = {
		-- The theme ships with rose-pine/neovim (lua/lualine/themes/rose-pine.lua),
		-- not with lualine. colorscheme.lua restyles this when `<leader>uc` cycles.
		theme = vim.g.lualine_theme or "rose-pine",
		globalstatus = true, -- one statusline for the window, not one per split
		section_separators = "",
		component_separators = "|",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = {
			{ "filename", path = 1 }, -- relative to cwd
			{ breadcrumbs },
		},
		lualine_x = {
			{ "diff", symbols = { added = "+", modified = "~", removed = "-" } },
			{ "diagnostics" },
			"filetype",
		},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	extensions = { "oil", "quickfix" },
})

-- bufferline ------------------------------------------------------------------
-- Open buffers along the top. <S-h>/<S-l> move between them; <leader>, opens
-- the fuzzy list for when there are more than fit up there.
require("bufferline").setup({
	options = {
		mode = "buffers", -- `close_command` unloads the buffer, it doesn't close a tab
		diagnostics = "nvim_lsp", -- error/warning count on each buffer's label
		diagnostics_indicator = function(_, _, diag)
			return (diag.error and " " .. diag.error or "") .. (diag.warning and " " .. diag.warning or "")
		end,
		show_buffer_close_icons = false,
		separator_style = "thin",
		always_show_bufferline = false, -- hide the bar when only one buffer is open
		offsets = {
			{ filetype = "oil", text = "Files", highlight = "Directory", separator = true },
		},
	},
})

-- Mini Sessions
require("mini.sessions").setup({
	autoread = false,
	autowrite = true,
})
