require("blink.cmp").setup({
  keymap = {
    -- Not Tab-to-accept: Tab is ambiguous while jumping snippet placeholders.
    preset = "default",
    -- "fallback" so Enter still makes a newline when nothing is selected.
    ["<CR>"] = { "accept", "fallback" },
  },

  appearance = {
    nerd_font_variant = "mono",
  },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = true },
    menu = {
      draw = {
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
    -- Prebuilt Rust matcher, falling back to pure-Lua rather than not starting.
    implementation = "prefer_rust_with_warning",
  },
})
