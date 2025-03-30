return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "ravitemer/mcphub.nvim"
        },
        config = function()
            require("codecompanion").setup({
                adapters = {
                    openai = function()
                        return require("codecompanion.adapters").extend("openai", {
                            env = {
                                api_key = "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"
                            }
                        })
                    end,
                    copilot = function()
                        return require("codecompanion.adapters").extend("copilot", {
                            schema = {
                                model = {
                                    default = "claude-3.7-sonnet"
                                }
                            }
                        })
                    end
                },
                opts = {
                    log_level = "DEBUG", -- or "TRACE"
                },
                strategies = {
                    chat = {
                        adapter = "copilot",
                    },
                    inline = {
                        adapter = "copilot",
                    },
                    copilot = {
                        adapter = "copilot"
                    }
                }
            })
        end
    }
}
