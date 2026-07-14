-- oil.nvim — file explorer that IS a buffer. Press `-` to open the current
-- file's directory; rename/move/delete files by editing lines like text, then
-- :w to apply. Replaces netrw. No sidebar, no tree state to manage.
return {
  "stevearc/oil.nvim",
  lazy = false,                       -- load on startup so it hijacks netrw
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    default_file_explorer = true,
    view_options = { show_hidden = true },
  },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
  },
}
