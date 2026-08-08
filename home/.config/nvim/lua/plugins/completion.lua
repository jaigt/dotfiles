-- Completion (blink.cmp).

require("blink.cmp").setup({
  keymap = {
    -- 'default' means: Ctrl-y accepts, Ctrl-n/Ctrl-p or arrows navigate.
    -- Deliberately NOT Tab-to-accept: Tab is ambiguous while jumping between
    -- snippet placeholders.
    preset = "default",
    -- Enter accepts too, but only when something is selected -- so pressing
    -- Enter to make a newline still makes a newline.
    ["<CR>"] = { "accept", "fallback" },
  },

  appearance = {
    nerd_font_variant = "mono", -- matches Caskaydia Cove Nerd Font
  },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = true },
    menu = {
      draw = {
        -- Show where each suggestion came from (LSP / Snippet / Buffer / Path).
        columns = {
          { "kind_icon" },
          { "label", "label_description", gap = 1 },
          { "source_name" },
        },
      },
    },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  signature = { enabled = true },

  fuzzy = {
    -- Use the prebuilt Rust matcher that ships with the tagged release; fall
    -- back to the pure-Lua one rather than failing to start.
    implementation = "prefer_rust_with_warning",
  },
})
