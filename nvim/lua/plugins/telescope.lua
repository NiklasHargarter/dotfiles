-- telescope — fuzzy finder for everything: files, live grep, open buffers, help,
-- diagnostics. The fzf-native extension makes matching fast (needs make + cc to
-- build once). All bindings live under <leader>f ("find"), shown by which-key.
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({})
    pcall(telescope.load_extension, "fzf")

    local builtin = require("telescope.builtin")
    local map = vim.keymap.set
    map("n", "<leader>ff", builtin.find_files,  { desc = "Find files" })
    map("n", "<leader>fg", builtin.live_grep,   { desc = "Grep in project" })
    map("n", "<leader>fb", builtin.buffers,     { desc = "Open buffers" })
    map("n", "<leader>fh", builtin.help_tags,   { desc = "Help tags" })
    map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics (project)" })
    map("n", "<leader>fr", builtin.resume,      { desc = "Resume last search" })
    map("n", "<leader>fw", builtin.grep_string, { desc = "Find word under cursor" })
  end,
}
