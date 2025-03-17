return {

    -- 1) Nvim Tree + Web Devicons
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup({
                view = {
                    width = 40,
                },
                filters = {
                    dotfiles = true,  -- show/hide dotfiles as needed
                    custom = { "node_modules", ".git" },
                },
                diagnostics = {
                    enable = true,
                    icons = {
                        hint = "",
                        info = "",
                        warning = "",
                        error = "",
                    },
                    show_on_dirs = true,
                },
                renderer = {
                    icons = {
                        show = {
                            folder = true,
                            file = true,
                            git = true,
                        },
                        glyphs = {
                            folder = {
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "",
                            },
                            git = {
                                unstaged = "✗",
                                staged = "✓",
                                unmerged = "",
                                renamed  = "➜",
                                untracked = "★",
                                deleted  = "",
                                ignored  = "◌",
                            }
                        },
                    },
                },
            })
        end
    },

    -- 2) Colorschemes
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,          -- load immediately so we can set the colorscheme
        priority = 1000,       -- ensure it loads first
        config = function()
            vim.cmd.colorscheme("rose-pine")
        end
    },
    {
        "sainnhe/gruvbox-material",  -- you can keep it if you want
    },

    -- 3) Airline
    {
        "vim-airline/vim-airline",
        config = function()
            vim.g.airline_theme = "gruvbox_material"
            vim.g.airline_powerline_fonts = 1
        end
    },

    -- 4) Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",   -- run TSUpdate after install
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "python", "javascript", "html", "css",
                    "typescript", "php", "json", "tsx"
                },
                highlight = { enable = true },
                incremental_selection = { enable = true },
                indent = { enable = true },
            })
        end
    },

    -- 5) Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local actions = require("telescope.actions")
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = {"node_modules", ".git"},
                    layout_strategy = "vertical",
                    layout_config = {
                        height = 0.95,
                        width = 0.9,
                        prompt_position = "top",
                        preview_cutoff = 120,
                        vertical = {mirror = false}
                    },
                    find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            })

            -- Optionally load fzf extension
            pcall(require("telescope").load_extension, "fzf")

            -- Keymaps (optional: you might want them in a separate file)
            vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { desc = "Find Files" })
            vim.keymap.set("n", "<leader><leader>f", function() require("telescope.builtin").git_files() end, { desc = "Git Files" })
            vim.keymap.set("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, { desc = "Live Grep" })
            vim.keymap.set("n", "<leader>fb", function() require("telescope.builtin").buffers() end,   { desc = "Buffers" })
            vim.keymap.set("n", "<leader>fh", function() require("telescope.builtin").help_tags() end, { desc = "Help Tags" })
            vim.keymap.set("n", "<leader>s",  function() require("telescope.builtin").lsp_workspace_symbols() end, { desc = "Workspace Symbols" })
        end
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },

    -- 6) LSP Config + blink cmp & extras
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "saghen/blink.cmp",
            "artemave/workspace-diagnostics.nvim"
        },
        config = function()
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            local lspconfig = require("lspconfig")

            -- TypeScript
            lspconfig.ts_ls.setup {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    -- If using prettier or something else, turn off ts_ls formatting
                    client.server_capabilities.documentFormattingProvider = false

                    local opts = { noremap=true, silent=true, buffer = bufnr }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                end,
           }

            -- Angular Language Server
            local cwd = vim.fn.getcwd()
            local handle = io.popen("npm root -g")
            local npmGlobalPath = handle:read("*a")
            handle:close()
            npmGlobalPath = npmGlobalPath:gsub("%s+$", "")

            local project_library_path = cwd .. "/node_modules"
            local cmd = {
                "node",
                npmGlobalPath .. "/@angular/language-server/bin/ngserver",
                "--ngProbeLocations", project_library_path,
                "--tsProbeLocations", project_library_path,
                "--stdio",
            }

            require'lspconfig'.angularls.setup{
                cmd = cmd,
                on_new_config = function(new_config, new_root_dir)
                    new_config.cmd = cmd
                end,

                on_attach = on_attach,
                on_attach = capabilities,
            }

        end
    },

    "rafamadriz/friendly-snippets",
    -- LuaSnip build step
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "rafamadriz/friendly-snippets"
        },
        build = "make install_jsregexp",  -- just replicate the do line
        version = "v2.3",
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end
    },

    -- 7) Trouble
    {
        "folke/trouble.nvim",
        position = "right",
        icons = true,
        mode = "document_diagnostics",
        use_diagnostic_signs = true
    },

    -- 8) gp.nvim
    {
        "robitx/gp.nvim",
        config = function()
            require("gp").setup({
                agents = {
                    {
                        provider = "openai",
                        name = "o3-mini test",
                        chat = true,
                        command = false,
                        model = { model = "o3-mini", temperature = 1.1, top_p = 1, max_completion_token = 10000 },
                        system_prompt = require("gp.defaults").chat_system_prompt,
                    },
                },
            })
        end
    },

    -- 9) mini.nvim
    {
        "echasnovski/mini.nvim",
        version = false,  -- stable is default if you want
        config = function()
            local mini_modules = {
                "ai",
                "pairs",
                "comment",
                "surround",
                "indentscope",
                "trailspace",
                "move",
                "splitjoin",
                "git",
                "notify",
            }
            for _, mod in ipairs(mini_modules) do
                require("mini." .. mod).setup()
            end

        end
    },

    -- 10) ThePrimeagen/vim-be-good
    {
        "ThePrimeagen/vim-be-good",
    },

    -- If you decide to use or keep codecompanion
    -- {
    --   "olimorris/codecompanion.nvim"
    -- },
}
