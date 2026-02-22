-- Autocommands

-- Watch for file changes and reload automatically
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	command = "checktime",
})

-- :SavePDF [font] — pick a folder via Telescope, enter filename, save .md as PDF
vim.api.nvim_create_user_command("SavePDF", function(opts)
	local buf = vim.api.nvim_buf_get_name(0)
	if not buf:match("%.md$") then
		vim.notify("SavePDF: current file is not a .md file", vim.log.levels.ERROR)
		return
	end

	local font = opts.args ~= "" and opts.args or "JetBrainsMono Nerd Font"
	local home = vim.env.HOME

	-- Use fd to find all directories under $HOME, feed into Telescope
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "SavePDF — select folder",
			finder = finders.new_oneshot_job(
				{ "fd", "--type", "d", "--hidden", "--exclude", ".git", ".", home },
				{ entry_maker = function(line)
					local display = line:gsub("^" .. vim.pesc(home), "~")
					return { value = line, display = display, ordinal = display }
				end }
			),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if not entry then return end

					local dir = entry.value:gsub("/$", "")
					local default_name = vim.fn.fnamemodify(buf, ":t:r") .. ".pdf"

					vim.ui.input({ prompt = "Filename: ", default = default_name }, function(name)
						if not name or name == "" then return end
						if not name:match("%.pdf$") then name = name .. ".pdf" end

						local output = dir .. "/" .. name
						local cmd = {
							"mdpdf", buf, "-o", output,
							"--mainfont", font,
							"--monofont", font,
						}

						vim.system(cmd, {}, function(result)
							vim.schedule(function()
								if result.code == 0 then
									vim.notify("SavePDF: saved to " .. output:gsub("^" .. vim.pesc(home), "~"))
								else
									vim.notify("SavePDF: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
								end
							end)
						end)
					end)
				end)
				return true
			end,
		})
		:find()
end, {
	nargs = "?",
	desc = "Save current .md file as PDF via mdpdf (interactive folder picker)",
})

-- Format on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
