local M = {}

M.create_system_executor = function(program)
    return function(block)
        local tempfile = vim.fn.tempname()
        vim.fn.writefile(vim.split(block.body, "\n"), tempfile)
        local result = vim.system({ "node", tempfile }, { text = true }):wait()
        return vim.split(result.stdout, "\n")
    end
end

---@param block present.Block
local execute_lua_code = function(block)
    local output = {}
    local original_print = print

    print = function(...)
        local args = { ... }
        local message = table.concat(vim.tbl_map(tostring, args), "\t")
        table.insert(output, message)
    end

    local chunk = loadstring(block.body)

    pcall(function()
        if not chunk then
            table.insert(output, "<<<BROKEN CODE>>>")
        else
            chunk()
        end
    end)

    print = original_print

    return output
end

local options = {
    executors = {
        lua = execute_lua_code,
        javascript = M.create_system_executor("node")
    }
}

M.setup = function(opts)
    opts = opts or {}
    opts.executors = opts.executors or {}
    opts.executors.lua = opts.executors.lua or execute_lua_code
    opts.executors.javascript = opts.executors.javascript or M.create_system_executor("node")

    options = opts
end

---@class present.WindowConfigurations
---@field background vim.api.keyset.win_config
---@field header vim.api.keyset.win_config
---@field body vim.api.keyset.win_config
---@field footer vim.api.keyset.win_config

---@class present.Slides
---@field slides present.Slide[]

---@class present.Slide
---@field title string:
---@field body string[]
---@field blocks present.Block[]: A codeblock inside of a slide

---@class present.Block
---@field language string: the language of the code block
---@field body string: The body of the code block


---Create the windows that we are going to use
---@return present.WindowConfigurations
local create_window_configurations = function()
    local width = vim.o.columns
    local height = vim.o.lines

    local header_height = 1 + 2                                        --top and bottom border
    local footer_height = 1                                            --no border
    local body_height = height - header_height - footer_height - 2 - 1 --top and bottom border

    return {
        ---@type vim.api.keyset.win_config
        background = {
            style = "minimal",
            relative = "editor",
            width = width,
            height = height,
            col = 0,
            row = 0,
            zindex = 1
        },
        ---@type vim.api.keyset.win_config
        header = {
            style = "minimal",
            relative = "editor",
            width = width,
            height = 1,
            col = 0,
            row = 0,
            border = "rounded",
            zindex = 2
        },
        ---@type vim.api.keyset.win_config
        footer = {
            style = "minimal",
            relative = "editor",
            width = width,
            height = 1,
            col = 0,
            row = height - 1,
            zindex = 2
        },
        ---@type vim.api.keyset.win_config
        body = {
            style = "minimal",
            relative = "editor",
            width = width - 8,
            height = body_height - 5,
            col = 7,
            row = 4,
            border = { " ", " ", " ", " ", " ", " ", " ", " ", },
            zindex = 2,
        },
    }
end

local function open_floating_window(config)
    config = config or {}

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, config)

    return { buf = buf, win = win }
end

---Take some lines and parses them
---@param lines string[]: the lines in the buffer
---@return present.Slides
local parse_slides = function(lines)
    local slides = { slides = {} }
    local current_slide = {
        title = "",
        body = {},
        blocks = {}
    }

    local separator = "^#"

    for i, line in ipairs(lines) do
        if line:find(separator) then
            if #current_slide.title > 0 then
                table.insert(slides.slides, current_slide)
            end

            current_slide = {
                title = line,
                body = {},
                blocks = {}
            }
        else
            table.insert(current_slide.body, line)
        end
    end

    table.insert(slides.slides, current_slide)

    local block_indicator = "```"

    for _, slide in ipairs(slides.slides) do
        ---@type present.Block
        local block = {
            language = "",
            body = ""
        }
        local inside_block = false

        for _, line in ipairs(slide.body) do
            if vim.startswith(line, block_indicator) then
                if inside_block then
                    inside_block = false
                    table.insert(slide.blocks, block)
                else
                    inside_block = true
                    block.language = string.sub(line, 4)
                end
            elseif inside_block then
                block.body = block.body .. line .. "\n"
            end
        end
    end

    return slides
end

local state = {
    parsed = {},
    title = "",
    current_slide = 1,
    floats = {
        background = {},
        header = {},
        footer = {},
        body = {},
    }
}

local foreach_float = function(cb)
    for name, float in pairs(state.floats) do
        cb(name, float)
    end
end

local set_slide_content = function(idx)
    local slide = state.parsed.slides[idx]
    local padding = string.rep(" ", (vim.o.columns - #slide.title) / 2)
    local title = padding .. slide.title
    local footer = string.format(" %d / %d | %s", state.current_slide, #state.parsed.slides, state.title)

    vim.api.nvim_buf_set_lines(state.floats.header.buf, 0, -1, false, { title })
    vim.api.nvim_buf_set_lines(state.floats.body.buf, 0, -1, false, slide.body)
    vim.api.nvim_buf_set_lines(state.floats.footer.buf, 0, -1, false, { footer })

    vim.api.nvim_set_current_win(state.floats.body.win)
end

local configure_keymaps = function()
    local present_keymap = function(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, { buffer = state.floats.body.buf }
        )
    end

    present_keymap("n", function()
        state.current_slide = math.min(state.current_slide + 1, #state.parsed.slides)
        set_slide_content(state.current_slide)
    end)

    present_keymap("p", function()
        state.current_slide = math.max(state.current_slide - 1, 1)
        set_slide_content(state.current_slide)
    end)

    present_keymap("q", function()
        vim.api.nvim_win_close(state.floats.body.win, true)
    end)

    present_keymap("X", function()
        local slide = state.parsed.slides[state.current_slide]
        local block = slide.blocks[1]

        if not block then
            print("No blocks on this slide")
            return
        end

        local executor = options.executors[block.language]

        if not executor then
            print("No valid executor for the language " .. block.language)
            return
        end

        local output = { "", "# Code", "", "```" .. block.language }
        vim.list_extend(output, vim.split(block.body, "\n"))
        table.insert(output, "```")

        table.insert(output, "")
        table.insert(output, "# Output ")
        table.insert(output, "")
        table.insert(output, "```")
        vim.list_extend(output, executor(block))
        table.insert(output, "```")

        local temp_width = math.floor(vim.o.columns * 0.8)
        local temp_height = math.floor(vim.o.lines * 0.8)

        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            style = "minimal",
            noautocmd = true,
            width = temp_width,
            height = temp_height,
            row = math.floor((vim.o.lines - temp_height) / 2),
            col = math.floor((vim.o.columns - temp_width) / 2),
            border = "rounded",
        })

        vim.bo[buf].filetype = "markdown"
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

        vim.keymap.set("n", "q", function()
            vim.api.nvim_win_close(win, true)
        end, { buffer = buf })

    end)
end

local configure_autocmds = function(restore)
    local present_autocmd = function(event, buffer, callback)
        vim.api.nvim_create_autocmd(event, {
            buffer = buffer,
            callback = callback
        })
    end

    present_autocmd("BufLeave", state.floats.body.buf,
        function()
            for key, value in pairs(restore) do
                vim.opt[key] = value.original
            end

            foreach_float(function(_, float)
                pcall(function() vim.api.nvim_win_close(float.win, true) end)
            end)
        end
    )

    present_autocmd("VimResized", state.floats.body.buf,
        function()
            if not vim.api.nvim_win_is_valid(state.floats.body.win) or state.floats.body.win == nil then
                return
            end

            local updated = create_window_configurations()

            foreach_float(function(name, float)
                vim.api.nvim_win_set_config(float.win, updated[name])
            end)

            set_slide_content(state.current_slide)
        end
    )
end


M.start_presentation = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0

    local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)

    state.parsed = parse_slides(lines)
    state.title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(opts.bufnr), ":t")
    state.current_slide = 1

    local windows = create_window_configurations()

    foreach_float(function(name, float)
        state.floats[name] = open_floating_window(windows[name])
        vim.bo[state.floats[name].buf].filetype = "markdown"
    end)

    local restore = {
        cmdheight = {
            original = vim.o.cmdheight,
            present = 0
        }
    }

    for key, value in pairs(restore) do
        vim.opt[key] = value.present
    end

    configure_keymaps()
    configure_autocmds(restore)
    set_slide_content(state.current_slide)
end


M.start_presentation({ bufnr = 13 })

M._parse_slides = parse_slides

return M
