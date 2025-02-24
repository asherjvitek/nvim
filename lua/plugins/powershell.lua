local p_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services"

local shell = "pwsh"

if vim.fn.executable('pwsh') == 0 then
    if vim.fn.executable('powershell') == 0 then
        --We do not have PowerShell and should not configure this
        return {}
    end

    shell = "powershell"
end

return {
    "asherjvitek/powershell.nvim",
    ---@type powershell.user_config
    opts = {
        bundle_path = p_path,
        shell = shell,
        root_dir = function(buf)
            return vim.fn.getcwd()
        end,
    },
}
