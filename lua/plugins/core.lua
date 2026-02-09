return {

	-- 1) Nvim Tree + Web Devicons
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				filesystem_watchers = {
					enable = false,
				},
				update_cwd = true,
				respect_buf_cwd = true,
				update_focused_file = {
					enable = true,
					update_cwd = false,
					ignore_list = {},
				},
				view = {
					width = 40,
				},
				filters = {
					dotfiles = true,
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
								unstaged  = "✗",
								staged    = "✓",
								unmerged  = "",
								renamed   = "➜",
								untracked = "★",
								deleted   = "",
								ignored   = "◌",
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
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("rose-pine")
		end
	},

	-- 3) Airline
	{
		"vim-airline/vim-airline",
		'vim-airline/vim-airline-themes',
		"tpope/vim-fugitive",
		"sainnhe/gruvbox-material",
		config = function()
			vim.g.airline_theme = "gruvbox_material"
			vim.g.airline_powerline_fonts = 1
			-- vim.g['airline#extensions#branch#enabled'] = 1
		end
	},

	-- 4) Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.config").setup({
				ensure_installed = {
					"lua", "python", "javascript", "html", "css",
					"typescript", "php", "json", "tsx"
				},
				highlight = { enable = true },
				incremental_selection = { enable = true },
				indent = { enable = true },
				autotag = { enable = true },
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
				},
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "TSUpdate",
				callback = function()
					require("nvim-treesitter.parsers").blade = {
						install_info = {
							url = "https://github.com/EmranMR/tree-sitter-blade",
							branch = "main",
							files = { "src/parser.c" },
							-- optional if repo has queries you want installed:
							-- queries = "queries/neovim",
						},
						filetype = "blade",
					}
				end,
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
					file_ignore_patterns = { "node_modules", ".git" },
					layout_strategy = "vertical",
					layout_config = {
						height = 0.95,
						width = 0.9,
						prompt_position = "top",
						preview_cutoff = 120,
						vertical = { mirror = false }
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

			-- Load fzf extension
			pcall(require("telescope").load_extension, "fzf")

			-- Keymaps
			vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files() end,
				{ desc = "Find Files" })
			vim.keymap.set("n", "<leader><leader>f", function() require("telescope.builtin").git_files() end,
				{ desc = "Git Files" })
			vim.keymap.set("n", "<leader>fg", function() require("telescope.builtin").live_grep() end,
				{ desc = "Live Grep" })
			vim.keymap.set("n", "<leader>fb", function() require("telescope.builtin").buffers() end, { desc = "Buffers" })
			vim.keymap.set("n", "<leader>fh", function() require("telescope.builtin").help_tags() end,
				{ desc = "Help Tags" })
			vim.keymap.set("n", "<leader>s", function() require("telescope.builtin").lsp_workspace_symbols() end,
				{ desc = "Workspace Symbols" })
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
			local util = require("lspconfig.util")
			local on_attach = function(_, bufnr)
				local opts = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			end

			-- HTML
			lspconfig.html.setup {
				capabilities = capabilities,
				on_attach = on_attach
			}

			-- JSON
			lspconfig.jsonls.setup {
				capabilities = capabilities,
				on_attach = on_attach
			}

			-- TypeScript
			lspconfig.ts_ls.setup {
				capabilities = capabilities,
				-- enable single‐file support so tsserver will attach
				single_file_support = true,

				-- if no project root is found, fall back to the file’s directory
				root_dir = function(fname)
					return util.root_pattern("package.json", "tsconfig.json", ".git")(fname)
						or util.path.dirname(fname)
				end,
				on_attach = function(client, bufnr)
					-- If using prettier or something else, turn off ts_ls formatting
					client.server_capabilities.documentFormattingProvider = false
					on_attach(client, bufnr)
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

			require 'lspconfig'.angularls.setup {
				cmd = cmd,
				capabilities = capabilities,
				on_new_config = function(new_config, new_root_dir)
					new_config.cmd = cmd
				end,

				on_attach = on_attach,
			}

			-- Rust
			lspconfig.rust_analyzer.setup {
				capabilities = capabilities,
				on_attach = on_attach,
				root_dir = util.root_pattern("Cargo.toml", "rust-project.json", ".git"),
			}

			-- Kotlin
			lspconfig.kotlin_language_server.setup {
				capabilities = capabilities,
				on_attach = on_attach
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
		build = "make install_jsregexp", -- just replicate the do line
		version = "v2.3",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end
	},

	-- 7) Trouble
	{
		"folke/trouble.nvim",
		opts = {
			modes = {
				diagnostics = {
					win = {
						position = "right",
						size = 0.25
					}
				}
			}
		},
		position = 'right',
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle win.position=right<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},

	-- 8) mini.nvim
	{
		"echasnovski/mini.nvim",
		version = false, -- stable is default if you want
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
				"sessions"
			}
			for _, mod in ipairs(mini_modules) do
				require("mini." .. mod).setup()
			end
		end
	},

	-- 9) ThePrimeagen/vim-be-good
	{
		"ThePrimeagen/vim-be-good",
	},
}
