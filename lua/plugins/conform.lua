return {
    'stevearc/conform.nvim',
    opts = {
        formatters_by_ft = {
            sql = { "sql_formatter" }
        },
    },
    keys = {
        {
            "<leader>F",
            function()
                require("conform").format({ async = true })
            end,
            mode = "",
            desc = "Format buffer",
        },
    },
}
