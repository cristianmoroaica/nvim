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
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'folke/trouble.nvim'
Plug 'robitx/gp.nvim'
Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.3', 'do': 'make install_jsregexp'}
call plug#end()

" Vim settings:
syntax on
colorscheme rose-pine
let g:airline_theme = 'gruvbox_material'
let g:airline_powerline_fonts = 1
highlight Comment guifg=#fc8803
let mapleader = " "
set number
set relativenumber
set termguicolors
set colorcolumn=80
" set textwidth=160
set wrap
set linebreak

nnoremap <leader>ns :vertical topleft split <Bar> terminal nx serve<CR>
nnoremap <leader>rnm :vertical topleft split <Bar> terminal npx react-native start<CR>
nnoremap <leader>rna :vertical topleft split <Bar> terminal npm run android<CR>
nnoremap <leader>rni :vertical topleft split <Bar> terminal npm run ios<CR>

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

local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>']      = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  },
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
      override_file_sorter = true,     -- override file sorte
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    }
  }
}

require("trouble").setup({
  -- your preferences
  position = "right",      -- position of the list can be: bottom, top, left, right
  icons = true,             -- use devicons for filenames
  mode = "document_diagnostics", -- default mode (options: document_diagnostics, workspace_diagnostics, quickfix, lsp_references, loclist)
  use_diagnostic_signs = true    -- enabling this uses the signs defined in your lsp client
})

require("gp").setup({
	agents = {
		{
			provider = "openai",
			name = "o3-mini test",
			chat = true,
			command = false,
			-- string with model name or table with model name and parameters
			model = { model = "o3-mini", temperature = 1.1, top_p = 1, max_completion_token = 10000 },
			-- system prompt (use this to specify the persona/role of the AI)
			system_prompt = require("gp.defaults").chat_system_prompt,
		},
	}
})

-- Load the fzf extension if available:
pcall(require('telescope').load_extension, 'fzf')


-- Keymaps:
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = "Live Grep" })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers,   { desc = "Buffers" })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = "Help Tags" })

local function keymapOptions(desc)
    return {
        noremap = true,
        silent = true,
        nowait = true,
        desc = "GPT prompt " .. desc,
    }
end





EOF

