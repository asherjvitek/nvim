vim.keymap.set("n", "<leader>tp", function() require("powershell").toggle_term() end)
vim.keymap.set( {"n" , "v" }, "<leader>E", function() require("powershell").eval() end)
