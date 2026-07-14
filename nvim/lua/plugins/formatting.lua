-- conform.nvim — formats the buffer on save with the right tool per language.
-- Tools come from mason (stylua, prettier, shfmt, clang-format) or the language
-- toolchain (ruff via its LSP, rustfmt from rustup). Toggle it off globally with
-- :FormatToggle when you want to save without reformatting.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo", "FormatToggle" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      cpp = { "clang-format" },
      c = { "clang-format" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      yaml = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      markdown = { "prettier" },
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 800, lsp_format = "fallback" }
    end,
  },
  init = function()
    vim.api.nvim_create_user_command("FormatToggle", function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
      print("Format on save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
    end, { desc = "Toggle format-on-save" })
  end,
}
