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
                                api_key = os.getenv("OPENAI_API_KEY"),
                            }
                        })
                    end,
                    copilot = function()
                        return require("codecompanion.adapters").extend("copilot", {
                            schema = {
                                model = {
                                    default = "claude-sonnet-4"
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
