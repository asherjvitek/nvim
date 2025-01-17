return {
    'mbbill/undotree',
    config = function()
        vim.g.undotree_SetFocusWhenToggle = 1

        vim.keymap.set("n", "<leader>tu", "<CMD>UndotreeToggle<CR>", { desc = "[T]oggle [U]dotree" })
    end
}
