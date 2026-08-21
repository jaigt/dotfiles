require("mini.icons").setup()
-- Lets mini.icons answer to nvim-web-devicons, which some plugins still ask
-- for by name — saves installing a second icon plugin.
MiniIcons.mock_nvim_web_devicons()

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
		disabled_filetypes = { winbar = { "", "neo-tree", "ministarter" } },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { { "filename", file_status = true, newfile_status = true, path = 1 }, { breadcrumbs } },
		lualine_x = {
			{ "diff", symbols = { added = "+", modified = "~", removed = "-" } },

			{ "diagnostics" },
			"filetype",
		},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	winbar = {
		lualine_a = {},
		lualine_z = {
			{
				"buffers",
				mode = 2, -- name + index; <leader>1-9 jumps by these numbers
				show_modified_status = true,
				use_mode_colors = true,
				symbols = {
					modified = " ●",
					alternate_file = "",
					directory = "",
				},
			},
		},
	},
	inactive_winbar = {
		lualine_a = {
			{
				"filename",
				file_status = true,
				path = 1,
				symbols = {
					modified = "[+]",
					readonly = "[-]",
					unnamed = "[No Name]",
				},
			},
		},
	},
	extensions = { "oil", "quickfix", "neo-tree", "fzf" },
})
