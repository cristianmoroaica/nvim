return {
    {
        "cristianmoroaica/mimirs_notes.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        config = function()
            require("mimirs_notes").setup()
        end
    }
}
