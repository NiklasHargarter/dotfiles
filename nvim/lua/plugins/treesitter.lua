-- nvim-treesitter (`main` branch) — parses code into a syntax tree used for
-- accurate highlighting. On Neovim 0.12 the *highlighter itself is built into
-- core* (`vim.treesitter.start`); this plugin's only job now is downloading and
-- updating the parsers. That split is why this file is tiny and calls Neovim's
-- own API directly instead of a plugin module.
--
-- Parsers compile locally on install → needs a C compiler (see README).
-- Add a language: add it to `langs` and restart (`:TSInstall <lang>` for one-off).
-- Want treesitter-based indentation? It's opt-in — see the commented line below.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    local langs = {
      "lua", "vim", "vimdoc",              -- editing this config
      "python", "cpp", "c", "rust",        -- your programming languages
      "bash", "yaml", "json", "toml",      -- config / devops
      "dockerfile", "markdown", "markdown_inline", "gitignore",
    }
    -- install only what's missing (install() is async and a no-op otherwise)
    local ts = require("nvim-treesitter")
    local installed = ts.get_installed()
    local missing = vim.tbl_filter(function(l)
      return not vim.tbl_contains(installed, l)
    end, langs)
    if #missing > 0 then ts.install(missing) end

    -- Turn on Neovim's built-in treesitter highlighting for any buffer whose
    -- language has a parser. pcall so filetypes without one just fall back.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
        -- Opt in to treesitter indentation per buffer (uncomment to try):
        -- vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
