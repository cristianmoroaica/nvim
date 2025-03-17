return {
    {
        'rgroli/other.nvim',
        config = function()
            require("other-nvim").setup({
                mappings = {
                    {
                        pattern = "/src/app/(.*)/.*.ts$",
                        target = "/src/app/%1/%1.component.html",
                    },
                    {
                        pattern = "/src/app/(.*)/.*.html$",
                        target = "/src/app/%1/%1.component.ts",
                    }
                }
            })
        end
    }
}


