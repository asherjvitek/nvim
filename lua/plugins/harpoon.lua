--This lets you "Harpoon" files for fast access
return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup({})

        vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = '[H]arpoon [A]dd' })
        vim.keymap.set("n", "<leader>ho", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
            { desc = '[H]arpoon [O]pen' })

        vim.keymap.set("n", "<M-j>", function() harpoon:list():select(1) end, { desc = 'Harpoon Item 1' })
        vim.keymap.set("n", "<M-k>", function() harpoon:list():select(2) end, { desc = 'Harpoon Item 2' })
        vim.keymap.set("n", "<M-l>", function() harpoon:list():select(3) end, { desc = 'Harpoon Item 3' })
        vim.keymap.set("n", "<M-;>", function() harpoon:list():select(4) end, { desc = 'Harpoon Item 4' })

        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<M-n>", function() harpoon:list():next() end, { desc = '[H]arpoon [N]ext' })
        vim.keymap.set("n", "<M-p>", function() harpoon:list():prev() end, { desc = '[H]arpoon [P]revious' })
    end
}
