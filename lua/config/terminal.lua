vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

local state = {
    floating = {
        buf = -1, win = -1,
        buf1 = -1, win1 = -1,
        buf2 = -1, win2 = -1,
        buf3 = -1, win3 = -1,
    }
}

local function create_floating_window(opts)
    opts = opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.8)
    local height = opts.height or math.floor(vim.o.lines * 0.8)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local buf = vim.api.nvim_buf_is_valid(opts.buf) and opts.buf or vim.api.nvim_create_buf(false, true)

    local title_padding = "  " .. (opts.title or "Floating Terminal") .. "  "
    local win_config = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
        title = title_padding,
        title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
end

local function toggle_terminal(buf_key, win_key, title)
    buf_key = buf_key or "buf"
    win_key = win_key or "win"
    title = title or "General Terminal"

    local buf = state.floating[buf_key]
    local win = state.floating[win_key]

    -- Open window if not already valid
    if not vim.api.nvim_win_is_valid(win) then
        -- Reuse existing buffer or create new
        if buf == -1 or not vim.api.nvim_buf_is_valid(buf) then
            buf = vim.api.nvim_create_buf(false, true)
            state.floating[buf_key] = buf
        end

        -- Create floating window
        local floating_window = create_floating_window { buf = buf, title = title }
        state.floating[buf_key] = floating_window.buf
        state.floating[win_key] = floating_window.win

        -- Determine shell
        local shell
        if vim.loop.os_uname().sysname == "Windows_NT" then
            shell = "powershell.exe"
        else
            shell = os.getenv("SHELL") or "bash"
        end

        -- If buffer isn't already a terminal, open terminal
        if vim.api.nvim_buf_get_option(buf, "buftype") ~= "terminal" then
            vim.api.nvim_set_current_buf(buf)
            vim.fn.termopen(shell)
        else
            vim.api.nvim_set_current_buf(buf)
        end
    else
        -- Hide window if already open
        vim.api.nvim_win_hide(win)
    end
end

-- User Commands and Keymaps
vim.api.nvim_create_user_command("Floaterminal", function() toggle_terminal() end, {})
vim.keymap.set({"n", "t"}, "<leader>tt", function() toggle_terminal() end)
vim.keymap.set({"n", "t"}, "<leader>t1", function() toggle_terminal("buf1", "win1", "Background Terminal 1") end)
vim.keymap.set({"n", "t"}, "<leader>t2", function() toggle_terminal("buf2", "win2", "Background Terminal 2") end)
vim.keymap.set({"n", "t"}, "<leader>t3", function() toggle_terminal("buf3", "win3", "Background Terminal 3") end)

