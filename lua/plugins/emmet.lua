return {
    {
        "mattn/emmet-vim",
        ft = { "html", "css", "javascript", "javascriptreact", "typescriptreact", "vue" },
        config = function()
            -- Do not install globally; only enable for specified filetypes
            vim.g.user_emmet_install_global = 0
            -- Set your preferred leader key for Emmet (example: <C-Z>)
            vim.g.user_emmet_leader_key = '<C-Z>'
            -- Optionally, autoload Emmet for the specified filetypes
            vim.cmd([[
        autocmd FileType html,css,javascript,javascriptreact,typescriptreact,vue EmmetInstall
        ]])
        end,
    },
}
