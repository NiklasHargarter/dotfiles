-- Bootstrap lazy.nvim (the plugin manager) and hand it every spec file in
-- lua/plugins/. lazy.nvim only fetches, lazy-loads, and version-pins plugins —
-- the config in each spec is yours.
--
-- On first launch it clones itself, then clones every plugin at the versions
-- recorded in lazy-lock.json (committed to this repo). That lockfile is why a
-- fresh machine gets *exactly* the plugin versions you tested — run :Lazy update
-- to bump them, then commit the changed lockfile.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },        -- load every file in lua/plugins/
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false },            -- no background update checks; you own the lockfile
  change_detection = { notify = false },
  ui = { border = "rounded" },
})
