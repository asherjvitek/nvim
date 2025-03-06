--Quick and dirty way to send the messages to a new buffer so that you can do thing with them. Like copy and paste things from them.
vim.api.nvim_create_user_command("MessagesToBuffer", function()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)

    vim.keymap.set("n", "q", function ()
        vim.api.nvim_buf_delete(buf, { unload = true })
    end, { buffer = buf })

    vim.api.nvim_win_set_buf(win, buf)

    vim.cmd([[let @n=execute("messages") | put n]])
end, {})
