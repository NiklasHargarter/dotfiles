-- hardtime.nvim — the habit trainer. Blocks spamming `hjkl` / arrow keys more
-- than a few times in a row and pops a hint suggesting the better motion (`5j`,
-- `f`, `}`, `w`…). Annoying on purpose: that's how the good motions become muscle
-- memory again. Toggle off any time with `:Hardtime toggle` (or `:Hardtime off`
-- for a session where you just need to move).
return {
  "m4xshen/hardtime.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    max_count = 2,        -- repeats allowed before it blocks (default 3). Tightened
                          -- from 4: the point is to make the motion uncomfortable.
    disable_mouse = false, -- keep the mouse usable; the point is keyboard motion, not asceticism
  },
}
