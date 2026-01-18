return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup()
    wk.add({
      { "<leader>f", group = "find" },
      { "<leader>l", group = "other" },
      { "<leader>x", group = "trouble" },
      { "<leader>c", group = "code" },
    })
  end,
}
