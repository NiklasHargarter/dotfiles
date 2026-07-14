-- lualine — the statusline at the bottom: mode, git branch, filename,
-- diagnostics, position. Purely cosmetic; delete this file if you want the
-- stock Neovim statusline back.
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "tokyonight",
      globalstatus = true,               -- one statusline for all splits
      section_separators = "",
      component_separators = "",
    },
  },
}
