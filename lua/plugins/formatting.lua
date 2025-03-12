-- lua/plugins/neoformat.lua
return {
  "sbdchd/neoformat",
  event = "BufReadPre",
  config = function()
    -- We'll skip neoformat_try_node_exe and just call npx directly:
    vim.g.neoformat_html_prettier = {
      exe = "npx",
      args = {
        "prettier",
        "--stdin-filepath",
        vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
        "--plugin-search-dir=."
      },
      stdin = 1
    }

    vim.g.neoformat_enabled_html = { "prettier" }
  end,
}

