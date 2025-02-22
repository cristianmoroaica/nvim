call plug#begin(stdpath('data') . '/plugged')
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'ThePrimeagen/vim-be-good'
Plug 'sainnhe/gruvbox-material'
Plug 'vim-airline/vim-airline'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'rose-pine/neovim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'neovim/nvim-lspconfig'
call plug#end()

" Vim settings:
syntax on
colorscheme rose-pine
highlight Comment guifg=#fc8803
let mapleader = " "
set number
set relativenumber
set termguicolors

lua << EOF

require('nvim-tree').setup({
	view = {
		width = 40,
	},
	filters = {
    		dotfiles = false,  -- show/hide dotfiles as needed
    		custom = { "node_modules", ".git" },
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
      },
    },
  },
})

require('nvim-treesitter.configs').setup({
  -- Install languages
  ensure_installed = { "lua", "python", "javascript", "html", "css", "typescript", "php", "json", "tsx" },
  -- Enable syntax highlighting
  highlight = {
    enable = true,
  },
  -- Optional features
  incremental_selection = { enable = true },
  indent = { enable = true },
})

require('lspconfig').ts_ls.setup{
  on_attach = function(client, bufnr)
    -- Optionally disable tsserver's formatting if you use a separate formatter like prettier:
    client.server_capabilities.documentFormattingProvider = false

    -- Define your custom keymaps here:
    local opts = { noremap=true, silent=true }
    local buf_map = function(lhs, rhs)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, opts)
    end

    buf_map('gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
    buf_map('K', '<cmd>lua vim.lsp.buf.hover()<CR>')
    buf_map('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
    buf_map('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
    -- Add more mappings as needed...
  end,
}

require('telescope').setup{
  defaults = {
    -- Optional: Ignore patterns (for example, node_modules or .git directories)
    file_ignore_patterns = {"node_modules", ".git"},
    -- Layout and appearance settings can be customized here:
    layout_strategy = "vertical",
    layout_config = {
      height = 0.95,
      width = 0.9,
    },
    find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
  },
  -- Extensions configuration (if you installed telescope-fzf-native.nvim)
  extensions = {
    fzf = {
      fuzzy = true,                    -- enable fuzzy search
      override_generic_sorter = true,  -- override default sorter
      override_file_sorter = true,     -- override file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    }
  }
}

-- Load the fzf extension if available:
pcall(require('telescope').load_extension, 'fzf')


-- Keymaps:
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = "Live Grep" })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers,   { desc = "Buffers" })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = "Help Tags" })


EOF
