local M = {}


M.setup = function(opts)
    opts = opts or {}
end

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
    local buf = vim.api.nvim_create_buf(false, true)

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

---@class present.Slides
---@field slides string[]

---Take some lines and parses them
---@param lines string[]: the lines in the buffer
---@return present.Slides
local parse_slides = function(lines)
    local slides = { slides = {} }
    local current_slide = {}

    local separator = "^#"

    for i, line in ipairs(lines) do
        if line:find(separator) then
            if #current_slide > 0 then
                table.insert(slides.slides, current_slide)
            end

            current_slide = {}
        end


        table.insert(current_slide, line)
    end

    table.insert(slides.slides, current_slide)

    return slides
end

M.start_presentation = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0

    local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
    local parsed = parse_slides(lines)
    local float = open_floating_window({})

    local current_slide = 1
    vim.keymap.set("n", "n", function()
            current_slide = math.min(current_slide + 1, #parsed.slides)
            vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
        end,
        { buffer = float.buf })

    vim.keymap.set("n", "p", function()
            current_slide = math.max(current_slide - 1, 1)
            vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
        end,
        { buffer = float.buf })

    vim.keymap.set("n", "q", function () vim.api.nvim_win_close(float.win, true) end, { buffer = float.buf })

    vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[1])
end

M.start_presentation({ bufnr = 21 })

return M
