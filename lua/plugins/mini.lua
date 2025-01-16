return {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
        require("mini.pairs").setup()
        require("mini.cursorword").setup()
        require("mini.comment").setup()
    end
}
