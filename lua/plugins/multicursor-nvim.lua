return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
        local mc = require("multicursor-nvim")

        mc.setup()

        -- Add or skip cursor above/below the main cursor.
        vim.keymap.set({ "n", "v" }, "<M-k>", function() mc.lineAddCursor(-1) end)
        vim.keymap.set({ "n", "v" }, "<M-j>", function() mc.lineAddCursor(1) end)
        vim.keymap.set({ "n", "v" }, "<leader><M-k>", function() mc.lineSkipCursor(-1) end)
        vim.keymap.set({ "n", "v" }, "<leader><M-j>", function() mc.lineSkipCursor(1) end)

        -- Add or skip adding a new cursor by matching word/selection
        vim.keymap.set({ "n", "v" }, "<leader>n", function() mc.matchAddCursor(1) end)
        vim.keymap.set({ "n", "v" }, "<leader>s", function() mc.matchSkipCursor(1) end)
        vim.keymap.set({ "n", "v" }, "<leader>N", function() mc.matchAddCursor(-1) end)
        vim.keymap.set({ "n", "v" }, "<leader>S", function() mc.matchSkipCursor(-1) end)

        -- Add all matches in the document
        vim.keymap.set({ "n", "v" }, "<C-l>", mc.matchAllAddCursors)

        -- You can also add cursors with any motion you prefer:
        -- vim.keymap.set("n", "<right>", function()
        --     mc.addCursor("w")
        -- end)
        -- vim.keymap.set("n", "<leader><right>", function()
        --     mc.skipCursor("w")
        -- end)

        -- Rotate the main cursor.
        vim.keymap.set({ "n", "v" }, "<M-h>", mc.prevCursor)
        vim.keymap.set({ "n", "v" }, "<M-l>", mc.nextCursor)

        -- Delete the main cursor.
        vim.keymap.set({ "n", "v" }, "<leader>x", mc.deleteCursor)

        -- Add and remove cursors with control + left click.
        vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse)

        -- Easy way to add and remove cursors using the main cursor.
        vim.keymap.set({ "n", "v" }, "<c-q>", mc.toggleCursor)

        -- Clone every cursor and disable the originals.
        vim.keymap.set({ "n", "v" }, "<leader><c-q>", mc.duplicateCursors)

        vim.keymap.set("n", "<esc>", function()
            if not mc.cursorsEnabled() then
                mc.enableCursors()
            elseif mc.hasCursors() then
                mc.clearCursors()
            else
                vim.cmd("nohlsearch")
            end
        end)

        -- bring back cursors if you accidentally clear them
        vim.keymap.set("n", "<leader>gv", mc.restoreCursors)

        -- Align cursor columns.
        -- TODO: need different map
        vim.keymap.set("n", "<leader>ga", mc.alignCursors)

        -- Split visual selections by regex.
        vim.keymap.set("v", "S", mc.splitCursors)

        -- Append/insert for each line of visual selections.
        vim.keymap.set("v", "I", mc.insertVisual)
        vim.keymap.set("v", "A", mc.appendVisual)

        -- match new cursors within visual selections by regex.
        vim.keymap.set("v", "M", mc.matchCursors)

        -- Rotate visual selection contents.
        vim.keymap.set("v", "<leader>t", function() mc.transposeCursors(1) end)
        vim.keymap.set("v", "<leader>T", function() mc.transposeCursors(-1) end)

        -- Jumplist support
        vim.keymap.set({ "v", "n" }, "<c-i>", mc.jumpForward)
        vim.keymap.set({ "v", "n" }, "<c-o>", mc.jumpBackward)

        -- Customize how cursors look.
        local hl = vim.api.nvim_set_hl
        hl(0, "MultiCursorCursor", { link = "Cursor" })
        hl(0, "MultiCursorVisual", { link = "Visual" })
        hl(0, "MultiCursorSign", { link = "SignColumn" })
        hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
        hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end
}
