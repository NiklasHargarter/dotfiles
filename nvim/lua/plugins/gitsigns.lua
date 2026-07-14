-- gitsigns — shows added/changed/removed lines in the sign column and lets you
-- stage, reset, preview, and blame hunks without leaving the buffer. Hunk
-- navigation on ]c / [c; everything else under <leader>g ("git").
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(l, r, desc)
        vim.keymap.set("n", l, r, { buffer = bufnr, desc = desc })
      end
      map("]c", function() gs.nav_hunk("next") end, "Next git hunk")
      map("[c", function() gs.nav_hunk("prev") end, "Prev git hunk")
      map("<leader>gp", gs.preview_hunk, "Preview hunk")
      map("<leader>gs", gs.stage_hunk, "Stage hunk")
      map("<leader>gr", gs.reset_hunk, "Reset hunk")
      map("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("<leader>gd", gs.diffthis, "Diff this file")
    end,
  },
}
