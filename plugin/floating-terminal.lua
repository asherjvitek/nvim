local state = {
    floating = {
        buf = -1,
        win = -1
    }
}

-- Function to open a floating window with a specified percentage size
local function open_floating_window(opts)
    opts = opts or {}
    -- Get the screen width and height
    local screen_width = vim.api.nvim_get_option('columns')
    local screen_height = vim.api.nvim_get_option('lines')

    -- Set the percentage of screen space for width and height
    local width_percentage = 0.85  -- 40% of the screen width
    local height_percentage = 0.85 -- 30% of the screen height

    -- Calculate the actual width and height based on the percentage
    local width = math.floor(screen_width * width_percentage)
    local height = math.floor(screen_height * height_percentage)

    -- Create a new scratch buffer
    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end

    -- Define the floating window options
    local win_config = {
        style = "minimal",                              -- Use minimal style
        relative = "editor",                            -- Position relative to the whole editor
        row = math.floor((screen_height - height) / 2), -- Center vertically
        col = math.floor((screen_width - width) / 2),   -- Center horizontally
        width = width,                                  -- Set the window width
        height = height,                                -- Set the window height
        border = "rounded",                             -- Set the window border style
    }

    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
end

local function toggle_terminal()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        state.floating = open_floating_window({ buf = state.floating.buf })
        if vim.bo[state.floating.buf].buftype ~= "terminal" then
            vim.cmd(":terminal")
        end
    else
        vim.api.nvim_win_hide(state.floating.win)
    end
end
vim.api.nvim_create_user_command("FloatingTerminal", toggle_terminal, {})

vim.keymap.set("n", "<leader>tt", toggle_terminal, { desc = "Toggle Terminal" })
