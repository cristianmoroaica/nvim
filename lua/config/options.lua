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

-- Nvim Tree
vim.keymap.set("n", "<leader>e", "<cmd>:NvimTreeToggle<CR>")

-- Trim whitespace on current line:
vim.keymap.set("n", "<leader>tw", ":s/\\s\\+$//e<CR>")

-- Debugging
vim.keymap.set("n", "<leader>en", ":lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR, wrap = true})<CR>")
vim.keymap.set("n", "<leader>ep", ":lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR, wrap = true})<CR>")
vim.keymap.set("n", "<leader>eo", ":lua vim.diagnostic.open_float()<CR>")

-- Telescope
vim.keymap.set("n", "<leader>fs", ":Telescope lsp_document_symbols<CR>")
vim.keymap.set("n", "<leader>fw", ":Telescope lsp_workspace_symbols<CR>")
vim.keymap.set('n', '<leader>r', "<cmd>lua require('telescope.builtin').lsp_references()<CR>", { noremap = true, silent = true })

-- Gen (Ollama)
vim.keymap.set("n", "<leader>-", ":Gen<CR>")

-- Move lines and indent
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Add lines without entering insert mode
vim.keymap.set('n', '<leader>j', function()
  vim.fn.append(vim.fn.line('.'), '')
end, { desc = 'Add blank line below without entering insert mode' })
vim.keymap.set('n', '<leader>k', function()
  vim.fn.append(vim.fn.line('.') - 1, '')
end, { desc = 'Add blank line above without entering insert mode' })

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

-- Adjusting vertical window size
vim.keymap.set("n", "<leader>.", ":vertical resize -5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>,", ":vertical resize +5<CR>", { noremap = true, silent = true })

-- Color picker
vim.keymap.set("n", "<leader>cp", "<cmd>:CccPick<CR>")

-- Git add all, commit, push
function _G.gitAddCommitPush()
  local msg = vim.fn.input("Commit message: ")
  if msg == "" then
    print("No commit message provided. Aborting.")
    return
  end
  vim.schedule(function()
    vim.cmd("Git add -A")
    vim.cmd("Git commit -m `" .. vim.fn.shellescape(msg) .. "`")
    vim.cmd("Git push")
  end)
end

vim.api.nvim_set_keymap('n', '<leader>ac', ':lua gitAddCommitPush()<CR>', { noremap = true, silent = true })

