local notes_dir = vim.fn.expand("~/notes")
local repo_url = vim.env.NOTES_REPO

-- Guard: do nothing if NOTES_REPO is not set
if not repo_url or repo_url == "" then
	return
end

local last_push = 0
local debounce_sec = 5

--- Run a git command asynchronously in ~/notes.
--- @param args string[] git subcommand args (e.g. {"pull", "--rebase"})
--- @param opts? { on_exit?: fun(code: integer), silent?: boolean }
local function git(args, opts)
	opts = opts or {}
	local cmd = vim.list_extend({ "git", "-C", notes_dir }, args)
	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_exit = function(_, code)
			if code ~= 0 and not opts.silent then
				vim.schedule(function()
					vim.notify("notes-sync: git " .. args[1] .. " failed (exit " .. code .. ")", vim.log.levels.WARN)
				end)
			end
			if opts.on_exit then
				opts.on_exit(code)
			end
		end,
	})
end

--- Chain multiple git commands sequentially.
--- @param cmds { args: string[], silent?: boolean }[]
--- @param idx? integer
local function git_chain(cmds, idx)
	idx = idx or 1
	if idx > #cmds then
		return
	end
	local entry = cmds[idx]
	git(entry.args, {
		silent = entry.silent,
		on_exit = function(code)
			if code == 0 then
				git_chain(cmds, idx + 1)
			end
		end,
	})
end

--- Pull from remote.
local function pull()
	git({ "pull", "--rebase" }, { silent = true })
end

--- Add, commit, and push the current change.
local function commit_and_push(filename)
	local now = vim.uv.now() / 1000
	if now - last_push < debounce_sec then
		return
	end
	last_push = now

	git_chain({
		{ args = { "add", "-A" } },
		{ args = { "commit", "-m", "update " .. filename }, silent = true },
		{ args = { "push" }, silent = true },
	})
end

--- First-time init: git init, add remote, initial commit, push.
local function init_repo()
	vim.notify("notes-sync: initializing " .. notes_dir, vim.log.levels.INFO)
	git_chain({
		{ args = { "init" } },
		{ args = { "remote", "add", "origin", repo_url } },
		{ args = { "add", "-A" } },
		{ args = { "commit", "-m", "initial commit" } },
		{ args = { "branch", "-M", "main" } },
		{ args = { "push", "-u", "origin", "main" } },
	})
end

--- Manual sync: pull then push everything.
local function manual_sync()
	vim.notify("notes-sync: syncing...", vim.log.levels.INFO)
	git({ "pull", "--rebase" }, {
		on_exit = function(code)
			if code == 0 then
				git_chain({
					{ args = { "add", "-A" } },
					{ args = { "commit", "-m", "manual sync" }, silent = true },
					{ args = { "push" }, silent = true },
				})
			end
		end,
	})
end

-- Command
vim.api.nvim_create_user_command("NotesSync", manual_sync, { desc = "Notes: pull then push" })

-- Autocmds
local group = vim.api.nvim_create_augroup("NotesSync", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	callback = function()
		if vim.fn.isdirectory(notes_dir .. "/.git") == 1 then
			pull()
		elseif vim.fn.isdirectory(notes_dir) == 1 then
			init_repo()
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	pattern = vim.fn.expand("~/notes") .. "/*",
	callback = function(ev)
		if vim.fn.isdirectory(notes_dir .. "/.git") == 0 then
			return
		end
		local filename = vim.fn.fnamemodify(ev.file, ":t")
		commit_and_push(filename)
	end,
})
