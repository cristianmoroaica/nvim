return {
    {
      dir = vim.fn.stdpath("config"),
      name = "resmon-local",
      config = function()
        require("config.resmon").setup({
          module = "config.resmon",
          interval_ms = 1000,
          icons = true,
        })
      end
    }
}
