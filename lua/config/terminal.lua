vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

local state = {
    floating = {
        buf = -1,
        buf1 = -1,
        buf2 = -1,
        buf3 = -1,
        win = -1,
        win1 = -1,
        win2 = -1,
        win3 = -1,
    }
}

local function create_floating_window(opts)
    opts = opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.8)
    local height = opts.height or math.floor(vim.o.lines * 0.8)

    -- Calculate the position to center the window
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Create a buffer
    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
    end


    local title_padding = "  " .. (opts.title or "Floating Terminal") .. "  "

    -- Define window configuration
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

    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
end

local function toggle_terminal(buf_key, win_key, title)
    buf_key = buf_key or "buf"
    win_key = win_key or "win"
    title = title or "General Terminal"

    if not vim.api.nvim_win_is_valid(state.floating[win_key]) then
        state.floating[buf_key] = state.floating[buf_key] ~= -1 and state.floating[buf_key] or vim.api.nvim_create_buf(false, true)
        local floating_window = create_floating_window { buf = state.floating[buf_key], title = title }
        state.floating[buf_key] = floating_window.buf
        state.floating[win_key] = floating_window.win
        if vim.bo[state.floating[buf_key]].buftype ~= "terminal" then
            vim.cmd.terminal()
        end
    else
        vim.api.nvim_win_hide(state.floating[win_key])
    end
end

-- Example usage:
-- Create a floating window with default dimensions
vim.api.nvim_create_user_command("Floaterminal", function() toggle_terminal() end, {})

vim.keymap.set({"n", "t"}, "<leader>tt", function() toggle_terminal() end)
vim.keymap.set({"n", "t"}, "<leader>t1", function() toggle_terminal("buf1", "win1", "Background Terminal 1") end)
vim.keymap.set({"n", "t"}, "<leader>t2", function() toggle_terminal("buf2", "win2", "Background Terminal 2") end)
vim.keymap.set({"n", "t"}, "<leader>t3", function() toggle_terminal("buf3", "win3", "Background Terminal 3") end)

