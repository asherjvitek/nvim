local plugins = {}

return {
    -- { dir = "~\\source\\repos\\asp-code-monkey-nvim" }
    { dir = vim.fn.stdpath("config") .. "/lua/config/present.nvim", config = function ()
        require("present")
    end }
}
