return {
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({
                "*",
                css = { names = true },
                json = { names = true },
            })
        end,
    }
}
