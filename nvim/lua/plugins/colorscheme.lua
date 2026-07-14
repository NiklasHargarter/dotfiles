-- tokyonight — colourscheme. Loaded eagerly (lazy=false, high priority) so the
-- UI is themed before anything else draws. Change `style` to "storm"/"moon"/
-- "day" or swap the whole plugin for another theme in one file.
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tokyonight").setup({ style = "night" })
    vim.cmd.colorscheme("tokyonight")
  end,
}
