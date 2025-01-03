require("config.settings")
require("config.keymaps")
require("config.usercmd")

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    pattern = "*",
    desc = "Highlight when yanking text"
})
