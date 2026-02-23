-- Disable mini.trailspace on snacks dashboard.
-- mini.trailspace's deferred matchadd runs before UIEnter (when the dashboard opens),
-- so the match is applied to the window while buf 1 is still normal. The dashboard
-- then reuses that window, inheriting the stale match. Remove it once the dashboard opens.
vim.api.nvim_create_autocmd("User", {
	pattern = "SnacksDashboardOpened",
	callback = function()
		vim.b.minitrailspace_disable = true
		if _G.MiniTrailspace then
			MiniTrailspace.unhighlight()
		end
	end,
})

require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.terminal")
require("config.news")
require("config.dotenv")
