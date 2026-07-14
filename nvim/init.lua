-- ~/.config/nvim/init.lua — entry point.
--
-- This config is small and hand-written on purpose. Every plugin lives in its
-- own file under lua/plugins/ with a comment saying what it does and which
-- keymaps it owns. Nothing here is a framework — read it top to bottom and you
-- know your whole editor. See README.md for the full keymap cheatsheet.
--
-- Load order matters: options + keymaps set globals (leader key!) that plugins
-- read at load time, so they must run before lazy.nvim bootstraps the plugins.

require("config.options")
require("config.keymaps")
require("config.lazy")
