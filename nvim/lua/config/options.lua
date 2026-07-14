-- Core editor behaviour. Plain vim.opt settings — no plugin needed for any of
-- this. Leader is set first because plugins capture it when they load.

vim.g.mapleader = " "       -- <leader> = spacebar (used by most keymaps)
vim.g.maplocalleader = " "

local opt = vim.opt

-- Lines & navigation
opt.number = true           -- absolute line number on the cursor line
opt.relativenumber = true   -- relative numbers elsewhere → fast j/k motions (5j)
opt.cursorline = true       -- highlight the current line
opt.scrolloff = 8           -- keep 8 lines of context above/below cursor
opt.wrap = false            -- don't soft-wrap long lines
opt.signcolumn = "yes"      -- always show the sign gutter (git/diagnostics) — no jitter

-- Indentation: 2 spaces, no tabs. clang-format/ruff override per-language anyway.
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- Search
opt.ignorecase = true       -- case-insensitive...
opt.smartcase = true        -- ...unless the query has a capital letter
opt.hlsearch = true

-- System clipboard: yank/paste shares the OS clipboard. Comment out to keep
-- vim registers separate from the system if you prefer explicit "+y.
opt.clipboard = "unnamedplus"

-- Splits open where you expect them
opt.splitright = true
opt.splitbelow = true

-- Files: no swap/backup, but keep persistent undo across sessions
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- UX
opt.mouse = "a"             -- mouse works (scroll, resize splits) — off = ""
opt.termguicolors = true    -- 24-bit colour (required by tokyonight)
opt.updatetime = 250        -- faster CursorHold (gitsigns, diagnostics)
opt.timeoutlen = 400        -- how long which-key waits before popping up
opt.confirm = true          -- prompt to save instead of failing :q on a dirty buffer

-- Disable the legacy remote-plugin provider hosts (perl/ruby/node/python). We
-- use none of them; turning them off keeps :checkhealth clean so real problems
-- stand out. Re-enable one by deleting its line if a plugin ever needs it.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
