require('config.settings')
require('config.keymaps')
require('config.usercmd')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

require("config.treesitter")
require("config.lsp")

require('oil').setup({
    skip_confirm_for_simple_edits = true,
    view_options = {
        show_hidden = true,
    }
});
