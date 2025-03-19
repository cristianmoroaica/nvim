-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.colorcolumn = "100"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4      -- Number of spaces that a <BS> will delete
vim.opt.expandtab = true     -- Use spaces instead of tabs
vim.opt.autoindent = true    -- Copy indent from current line when starting a new line
vim.opt.smartindent = true

vim.cmd [[
  highlight Comment guifg=#fc9900
]]

-- Nx / React Native Mappings
vim.keymap.set("n", "<leader>ns",  ":vertical topleft split | terminal nx serve<CR>")
vim.keymap.set("n", "<leader>nb",  ":vertical topleft split | terminal nx build --configuration=production<CR>")
vim.keymap.set("n", "<leader>rns", ":vertical topleft split | terminal npx react-native start<CR>")
vim.keymap.set("n", "<leader>rna", ":vertical topleft split | terminal npm run android<CR>")
vim.keymap.set("n", "<leader>rni", ":vertical topleft split | terminal npm run ios<CR>")

-- Trim whitespace on current line:
vim.keymap.set("n", "<leader>tw", ":s/\\s\\+$//e<CR>")

-- Debugging
vim.keymap.set("n", "<leader>en", ":lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR, wrap = true})<CR>")
vim.keymap.set("n", "<leader>ep", ":lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR, wrap = true})<CR>")
vim.keymap.set("n", "<leader>ed", ":lua vim.diagnostic.open_float()<CR>")

-- Telescope
vim.keymap.set("n", "<leader>fs", ":Telescope lsp_document_symbols<CR>")
vim.keymap.set("n", "<leader>fw", ":Telescope lsp_workspace_symbols<CR>")
vim.keymap.set('n', '<Leader>r', "<cmd>lua require('telescope.builtin').lsp_references()<CR>", { noremap = true, silent = true })

-- Gen (Ollama)
vim.keymap.set("n", "<leader>-", ":Gen<CR>")

-- Move lines and indent
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Paste over selection
vim.keymap.set("x", "<leader>p", [["+dP]])
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- Import symbol under cursor
vim.keymap.set('n', '<leader>i', function()
    vim.lsp.buf.code_action({
        filter = function(action)
            return action.title:match("import") ~= nil
        end,
        apply = true
    })
end, { desc = 'Import symbol under cursor' })

-- Code actions
vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')

-- Other keymapping
vim.keymap.set("n", "<leader>ll", "<cmd>:Other<CR>")
vim.keymap.set("n", "<leader>ltn", "<cmd>:OtherTabNew<CR>")
vim.keymap.set("n", "<leader>lp", "<cmd>:OtherSplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lv", "<cmd>:OtherVSplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lc", "<cmd>:OtherClear<CR>", { noremap = true, silent = true })

-- Context specific bindings
vim.keymap.set("n", "<leader>lt", "<cmd>:Other test<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ls", "<cmd>:Other scss<CR>", { noremap = true, silent = true })

-- Insert mode navigation
vim.keymap.set("i", "<C-l>", "<C-o>l")
vim.keymap.set("i", "<C-h>", "<C-o>h")
vim.keymap.set("i", "<C-j>", "<C-o>j")
vim.keymap.set("i", "<C-k>", "<C-o>k")

-- Remapping notes
vim.keymap.set("n", "<leader>nl", "<cmd>:NotesList<CR>", { noremap = true, silent = true })

