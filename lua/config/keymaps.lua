-- Keymaps

-- Nvim Tree
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")

-- Trim whitespace on current line
vim.keymap.set("n", "<leader>tw", ":s/\\s\\+$//e<CR>")

-- Debugging
vim.keymap.set(
	"n",
	"<leader>en",
	":lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR, wrap = true})<CR>"
)
vim.keymap.set(
	"n",
	"<leader>ep",
	":lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR, wrap = true})<CR>"
)
vim.keymap.set("n", "<leader>eo", ":lua vim.diagnostic.open_float()<CR>")

-- Telescope
vim.keymap.set("n", "<leader>fs", ":Telescope lsp_document_symbols<CR>")
vim.keymap.set("n", "<leader>fw", ":Telescope lsp_workspace_symbols<CR>")
vim.keymap.set(
	"n",
	"<leader>r",
	"<cmd>lua require('telescope.builtin').lsp_references()<CR>",
	{ noremap = true, silent = true }
)

-- Gen (Ollama)
vim.keymap.set("n", "<leader>-", ":Gen<CR>")

-- Move lines and indent
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Add lines without entering insert mode (safe on non-modifiable buffers)
local function ensure_modifiable()
	if not vim.bo.modifiable or vim.bo.readonly then
		vim.notify("Buffer is not modifiable", vim.log.levels.WARN)
		return false
	end
	return true
end

vim.keymap.set("n", "<leader>j", function()
	if not ensure_modifiable() then
		return
	end
	local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based
	-- insert below current line: start=end=row (0-based)
	vim.api.nvim_buf_set_lines(0, row, row, true, { "" })
end, { desc = "Add blank line below without entering insert mode" })

vim.keymap.set("n", "<leader>k", function()
	if not ensure_modifiable() then
		return
	end
	local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based
	local idx = math.max(row - 1, 0) -- convert to 0-based, clamp at top
	-- insert above current line: start=end=idx (0-based)
	vim.api.nvim_buf_set_lines(0, idx, idx, true, { "" })
end, { desc = "Add blank line above without entering insert mode" })

-- Paste over selection
vim.keymap.set("x", "<leader>p", [["+dP]])
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- Import symbol under cursor
vim.keymap.set("n", "<leader>i", function()
	vim.lsp.buf.code_action({
		filter = function(action)
			return action.title:match("import") ~= nil
		end,
		apply = true,
	})
end, { desc = "Import symbol under cursor" })

-- Code actions
vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")

-- Other keymapping
vim.keymap.set("n", "<leader>ll", "<cmd>Other<CR>")
vim.keymap.set("n", "<leader>ltn", "<cmd>OtherTabNew<CR>")
vim.keymap.set("n", "<leader>lp", "<cmd>OtherSplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lv", "<cmd>OtherVSplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lc", "<cmd>OtherClear<CR>", { noremap = true, silent = true })

-- Context specific bindings
vim.keymap.set("n", "<leader>lt", "<cmd>Other test<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ls", "<cmd>Other scss<CR>", { noremap = true, silent = true })

-- Insert mode navigation
vim.keymap.set("i", "<C-l>", "<C-o>l")
vim.keymap.set("i", "<C-h>", "<C-o>h")
vim.keymap.set("i", "<C-j>", "<C-o>j")
vim.keymap.set("i", "<C-k>", "<C-o>k")

-- Remapping notes
vim.keymap.set("n", "<leader>nl", "<cmd>NotesList<CR>", { noremap = true, silent = true })

-- Adjusting vertical window size
vim.keymap.set("n", "<leader>.", ":vertical resize -5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>,", ":vertical resize +5<CR>", { noremap = true, silent = true })

-- Color picker
vim.keymap.set("n", "<leader>cp", "<cmd>CccPick<CR>")

-- Git add all, commit, push
function _G.gitAddCommitPush()
	local msg = vim.fn.input("Commit message: ")
	if msg == "" then
		print("No commit message provided. Aborting.")
		return
	end
	vim.schedule(function()
		vim.cmd("Git add -A")
		vim.cmd("Git commit -m " .. vim.fn.shellescape(msg))
		vim.cmd("Git push")
	end)
end
vim.keymap.set("n", "<leader>ac", ":lua gitAddCommitPush()<CR>", { noremap = true, silent = true })

-- Resource monitor
vim.keymap.set("n", "<leader>rm", ":ResMonToggle<CR>")
