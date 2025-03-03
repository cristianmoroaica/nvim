-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.colorcolumn = "80"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4      -- Number of spaces that a <BS> will delete
vim.opt.expandtab = true     -- Use spaces instead of tabs
vim.opt.autoindent = true    -- Copy indent from current line when starting a new line
vim.opt.smartindent = true   -- Make auto-indenting smarter

vim.cmd [[
  highlight Comment guifg=#fc8803
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
vim.keymap.set("n", "<leader>en", ":lua vim.diagnostic.goto_next()<CR>")
vim.keymap.set("n", "<leader>ep", ":lua vim.diagnostic.goto_prev()<CR>")
-- Telescope
vim.keymap.set("n", "<leader>fs", ":Telescope lsp_document_symbols<CR>")
vim.keymap.set("n", "<leader>fw", ":Telescope lsp_workspace_symbols<CR>")
-- Gen (Ollama)
vim.keymap.set("n", "<leader>-", ":Gen<CR>")
-- Move lines and indent
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- Paste over selection
vim.keymap.set("x", "<leader>p", [["_dP]])
