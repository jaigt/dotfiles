require("mini.icons").setup()
-- Lets mini.icons answer to nvim-web-devicons, which some plugins still ask
-- for by name — saves installing a second icon plugin.
MiniIcons.mock_nvim_web_devicons()

-- which-key reads each keymap's `desc`; one defined without it shows as a
-- blank row.
require("which-key").setup({
	preset = "helix",
	delay = 400,
})

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

-- Breadcrumbs: "Class > method > block" for the cursor, off the treesitter tree.
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
	-- Runs on every statusline redraw, so bail on very large files.
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
		-- The theme ships with rose-pine/neovim, not lualine. colorscheme.lua
		-- restyles this on a cycle.
		theme = vim.g.lualine_theme or "rose-pine",
		globalstatus = true,
		section_separators = "",
		component_separators = "|",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = {
			{ "filename", path = 1 },
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

require("bufferline").setup({
	options = {
		mode = "buffers",
		diagnostics = "nvim_lsp",
		diagnostics_indicator = function(_, _, diag)
			return (diag.error and " " .. diag.error or "") .. (diag.warning and " " .. diag.warning or "")
		end,
		show_buffer_close_icons = false,
		separator_style = "thin",
		always_show_bufferline = false,
		offsets = {
			{ filetype = "oil", text = "Files", highlight = "Directory", separator = true },
		},
	},
})

require("mini.sessions").setup({
	autoread = false,
	autowrite = true,
})
