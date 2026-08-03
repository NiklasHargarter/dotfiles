-- flash.nvim — jump anywhere on screen in two keystrokes. Press `s` then type
-- any 2 characters you can see; matches get a label letter — press it to teleport
-- there. Kills the "hold j until I'm close" habit. Also upgrades `f`/`t`/`;`/`,`
-- (enhanced = true) so they show labels when the target repeats on the line.
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    modes = {
      char = { enabled = true }, -- enhance f/t/;/, with labels
    },
  },
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter select" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash (operator)" },
  },
}
