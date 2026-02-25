return {
	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			vim.g.vimtex_view_method = "zathura"
			vim.g.vimtex_compiler_method = "generic"
			vim.g.vimtex_compiler_generic = {
				command = "bash " .. vim.fn.expand("~/Projects/LaTeX/build.sh") .. " @tex",
				out_dir = "build",
			}
		end,
	}
}
