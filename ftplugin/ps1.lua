vim.keymap.set("n", "<leader>tp", function() require("powershell").toggle_term() end, { desc = "[T]oggle Powsershell Terminal" })
vim.keymap.set({ "n", "v" }, "<leader>E", function() require("powershell").eval() end, { desc = "[E]val Powershell" })
