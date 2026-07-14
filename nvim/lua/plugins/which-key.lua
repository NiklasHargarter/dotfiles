-- which-key — your antidote to "what does this keybinding do again?". Press
-- <leader> (space) and pause: a popup lists every binding under it with its
-- description. The `spec` below just names the groups so they read nicely.
-- Every keymap defined with a { desc = ... } shows up here automatically.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>c", group = "code" },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer-local keymaps (which-key)",
    },
  },
}
