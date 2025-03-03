return {
    -- TODO fsdfsdfsdfs
    -- ! Test
    -- WARNING sfsdfds
    -- FIX  dfsdfsdfsdfsd
    -- ? fsdfsd
    -- # Testing
    {
        "Djancyp/better-comments.nvim",
        config = function()
            require('better-comment').Setup({
                tags = {
                    {
                        name = "TODO",
                        fg = "white",
                        bg = "#0a7aca",
                        bold = true,
                        virtual_text = "",
                    },
                    {
                        name = "TO DO",
                        fg = "white",
                        bg = "#0a7aca",
                        bold = true,
                        virtual_text = "",
                    },
                    {
                        name = "FIX",
                        fg = "white",
                        bg = "#f44747",
                        bold = true,
                        virtual_text = "This needs fixing",
                    },
                    {
                        name = "WARN",
                        fg = "#FFA500",
                        bg = "",
                        bold = false,
                        virtual_text = "Keep an eye on this.",
                    },

                    {
                        name = "WARNING",
                        fg = "#FFA500",
                        bg = "",
                        bold = false,
                        virtual_text = "Keep an eye on this.",
                    },
                    {
                        name = "!",
                        fg = "#f44747",
                        bg = "",
                        bold = true,
                        virtual_text = " Important",
                    },
                    {
                        name = "?",
                        fg = "#0a7aca",
                        bg = "",
                        bold = true,
                        virtual_text = "󰘥",
                    },
                    {
                        name = "#",
                        bg = "#009144",
                        fg = "white",
                        bold = true,
                        virtual_text = "󰔨",
                    },
                    {
                        name = "*",
                        bg = "#0f6a44",
                        fg = "white",
                        bold = true,
                        virtual_text = "󰔨",
                    },

                }
            })
        end
    }
}
