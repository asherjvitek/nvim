vim.keymap.set("n", "<leader>tp", function()
        require("powershell").toggle_term()
    end,
    { desc = "[T]oggle Powsershell Terminal" }
)

vim.keymap.set({ "n", "v" }, "<leader>E", function()
    require("powershell").eval()

    --This sorta works. I think that we need some better hook that is on lsp done or something.
    local util = require("powershell.util")
    local buf = vim.api.nvim_get_current_buf()
    local term_buf = util.term_buf(buf)
    if term_buf ~= nil then
        vim.api.nvim_buf_call(term_buf, function()
            vim.cmd(":norm G")
        end)
    end
end, { desc = "[E]val Powershell" }
)
