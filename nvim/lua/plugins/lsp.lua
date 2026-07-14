-- LSP — language servers give you go-to-definition, hover docs, rename, and
-- inline diagnostics. Three pieces:
--   mason.nvim            downloads the server binaries (no system installs)
--   mason-lspconfig       maps mason names ↔ lspconfig names, ensures installed
--   nvim-lspconfig        ships the default config for each server
-- mason-tool-installer additionally grabs the non-LSP tools (formatters).
--
-- To add a language: install its server name into the `servers` table below and
-- restart — mason downloads it on next launch.
return {
  "neovim/nvim-lspconfig",
  -- VeryLazy (not BufReadPre) so mason + the :Mason command and auto-installs
  -- come up right after startup even in an empty `nvim` session. Servers still
  -- only attach when a matching file opens.
  event = "VeryLazy",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    -- server name → per-server overrides ({} = use lspconfig defaults)
    local servers = {
      lua_ls = {                                   -- editing this config
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      },
      pyright = {},                                -- python types
      ruff = {},                                   -- python lint + format
      clangd = {},                                 -- C / C++
      rust_analyzer = {},                          -- rust
      bashls = {}, yamlls = {}, jsonls = {},       -- config / devops
      taplo = {}, dockerls = {}, marksman = {},    -- toml / docker / markdown
    }

    require("mason-tool-installer").setup({
      ensure_installed = { "stylua", "prettier", "shfmt", "clang-format" },
    })
    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(servers),
      automatic_enable = false,                    -- we enable them explicitly below (full control)
    })

    -- Give every server blink.cmp's completion capabilities, then apply overrides
    -- and start it. vim.lsp.config / enable is the native Neovim 0.11+ API.
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
    for name, cfg in pairs(servers) do
      if next(cfg) ~= nil then vim.lsp.config(name, cfg) end
      vim.lsp.enable(name)
    end

    -- Buffer-local keymaps, set only once a server attaches to the buffer.
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
        end
        map("grd", vim.lsp.buf.definition, "Go to definition")
        map("grr", vim.lsp.buf.references, "References")
        map("gri", vim.lsp.buf.implementation, "Implementation")
        map("K",  vim.lsp.buf.hover, "Hover docs")
        map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
        map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
        map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
      end,
    })
  end,
}
