return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    })

    vim.keymap.set("n", "<leader>f", function()
      require("conform").format({ lsp_fallback = true })
    end, { desc = "Format buffer" })
  end,
}
