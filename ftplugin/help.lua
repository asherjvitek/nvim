vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
        vim.cmd.wincmd({ args = { "L" } })
    end,
    buffer = vim.api.nvim_get_current_buf(),
})
