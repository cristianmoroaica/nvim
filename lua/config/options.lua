-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.colorcolumn = "100"
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4 -- Number of spaces that a <BS> will delete
vim.opt.expandtab = false -- Use spaces instead of tabs
vim.opt.autoindent = true -- Copy indent from current line when starting a new line
vim.opt.smartindent = true

-- Enable autoread
vim.o.autoread = true

vim.o.updatetime = 1000 -- 1 second

-- Blade
vim.filetype.add({
	pattern = {
		[".*%.blade%.php"] = "blade",
	},
})

vim.cmd([[
  highlight Comment guifg=#fc9900
]])
