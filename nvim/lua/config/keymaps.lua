-- Global keymaps that don't belong to a specific plugin. Plugin-owned keymaps
-- live in that plugin's file (telescope.lua, gitsigns.lua, ...) so the binding
-- sits next to the thing it drives. which-key shows all of them when you press
-- <leader>, so you never have to memorise this file.

local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Window navigation with Ctrl+hjkl (instead of <C-w> then h)
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Keep cursor centred when jumping half-pages / through search results
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Save / quit
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })

-- Ask Claude — opens Claude Code in a Zellij floating pane next to the editor.
-- Deliberately NOT inline autocomplete: you ask a question, read the answer, and
-- it never touches your buffer. Closes when you exit claude. Falls back to a
-- nvim terminal split when you're not inside Zellij.
map("n", "<leader>a", function()
  if vim.env.ZELLIJ then
    vim.fn.system("zellij run --floating --close-on-exit -- claude")
  else
    vim.cmd("botright split | terminal claude")
  end
end, { desc = "Ask Claude (side pane)" })
