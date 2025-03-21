local util = require("util.powershell_util")
local powershell_shell = util.get_powershell_shell()

if powershell_shell == nil then
    return {}
end

local p_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services"

return {
    "TheLeoP/powershell.nvim",
    ---@type powershell.user_config
    opts = {
        bundle_path = p_path,
        shell = powershell_shell,
        root_dir = function(buf)
            return vim.fn.getcwd()
        end,
    },
}
