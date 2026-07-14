-- blink.cmp — the autocomplete popup as you type. Pulls suggestions from the
-- LSP, current buffer, file paths, and snippets. Near-zero config; ships a Rust
-- fuzzy matcher (downloaded prebuilt, no build step). This is plain completion,
-- NOT AI — it only ever suggests symbols that already exist.
--
-- Default keys: <C-space> open, <C-y> accept, <C-e> close, <C-n>/<C-p> or
-- <Tab>/<S-Tab> to cycle. Change `keymap.preset` to "super-tab" or "enter" to taste.
return {
  "saghen/blink.cmp",
  version = "1.*",                                  -- use a tagged release (prebuilt binary)
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    signature = { enabled = true },                 -- show function signature while typing args
  },
}
