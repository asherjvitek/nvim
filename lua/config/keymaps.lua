-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

local copy_buffer_path = function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg('+', path)
    print(path, "copied to + register")
end

vim.keymap.set("n", "<leader>yp", copy_buffer_path, { desc = "[Y]ank Current Buffer [P]ath" })
-- vim.keymap.set('n', '<leader>j', vim.cmd.Ex, { desc = ':Ex' })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

--I think that this would likely make some people really mad....
vim.keymap.set({ "i", "c" }, "<C-H>", "<C-W>", { desc = "CTRL Backspace works like it does other places" })

--This works in VS but I could not get J or K with this map to work there so we have this.
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move text up" })
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move text down" })
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move text up" })

vim.keymap.set("n", "<leader>rt", ":%s/\t/    /g<CR>", { desc = "[R]eplace [T]abs with spaces" })
--End of the hate

-- Window maps
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

--Navigation quality of life
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Half page down keep center' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Half page up keep center' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next keep center' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous keep center' })

--Maniplulation into the P register instead of the default. this is like a secondary paste and delete that is not the clipboard.
vim.keymap.set({ "n", "v" }, "<leader>y", [["py]], { desc = '[Y]ank into p register' })
vim.keymap.set({ "n", "v" }, "<leader>p", [["pp]], { desc = '[P]aste below from p register' })
vim.keymap.set({ "n", "v" }, "<leader>P", [["pP]], { desc = '[P]aste above from p register' })
vim.keymap.set({ "n", "v" }, "<leader>d", [["pd]], { desc = '[D]elete into p register' })
vim.keymap.set({ "n", "v" }, "<leader>c", [["pc]], { desc = '[C]hange into p register' })

vim.keymap.set("n", "<leader>sc", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = '[S]ubstitute [C]urrent word' })
vim.keymap.set("v", "<leader>sc", [[y :%s/<C-r>"/<C-r>"/gI<Left><Left><Left>]], { desc = '[S]ubstitute [C]urrent word' })

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = '[E]xit Terminal Insert Mode' })
-- We have multicursor handling this for the moment
-- vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*_spec.lua",
    callback = function()
        vim.keymap.set("n", "<leader>rt", "<cmd>PlenaryBustedFile %<CR>",
            { desc = "[R]un PlenaryBustedFile [T]est", buffer = vim.api.nvim_get_current_buf() })
    end
})

--quickfix
vim.keymap.set('n', '<leader>qn', "<cmd>cnext<CR>", { desc = '[Q]uickfix [N]ext' })
vim.keymap.set('n', '<leader>qp', "<cmd>cprev<CR>", { desc = '[Q]uickfix [P]revious' })
