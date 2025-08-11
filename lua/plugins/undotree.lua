return {
    'mbbill/undotree',
    config = function()
        vim.g.undotree_SetFocusWhenToggle = 1

        if vim.loop.os_uname().sysname == 'Windows_NT' then
            vim.g.undotree_DiffCommand = "FC"
        end

        vim.keymap.set("n", "<leader>tu", "<CMD>UndotreeToggle<CR>", { desc = "[T]oggle [U]dotree" })
    end
}
