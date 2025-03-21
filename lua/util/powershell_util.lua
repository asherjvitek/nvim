M = {}

M.get_powershell_shell = function ()
    local use_powershell = os.getenv("NVIM_USE_POWERSHELL")
    local powershell_shell = nil
    local have_pwsh = vim.fn.executable('pwsh');
    local have_powershell = vim.fn.executable('powershell');

    if have_pwsh then
        powershell_shell = "pwsh"
    end

    if have_pwsh == 0 and have_powershell == 1 then
        powershell_shell = "powershell"
    end

    if use_powershell == "1" and have_powershell == 1 then
        powershell_shell = "powershell"
    end

    return powershell_shell
end

return M
