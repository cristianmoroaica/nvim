return {
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",
		opts = {
			keymaps = {
				conflict = {
					accept_incoming = "<leader>ci",
					accept_current = "<leader>cc",
					accept_both = "<leader>cb",
					next_conflict = "<leader>cn",
					previous_conflict = "<leader>cp",
				}
			}
		}
	}
}
