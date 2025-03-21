-- [[ Setting options ]]

-- Set highlight on search
vim.opt.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

vim.o.termguicolors = true

vim.o.scrolloff = 10
vim.o.wrap = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.cursorline = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.timeoutlen = 300

vim.opt.inccommand = 'split'

if vim.loop.os_uname().sysname == 'Windows_NT' then
    local util = require("util.powershell_util")
    local powershell_shell = util.get_powershell_shell()

    --If we have powershell then we are on windows and would like to use that for our shell.
    if powershell_shell ~= nil then
        --Make it so that powershell is the default sheel that is used.
        vim.o.shell = powershell_shell
        vim.o.shellcmdflag =
        "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
        vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
        vim.o.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'

        --I have not translated this because I could not figure out how to make these work.
        vim.cmd([[ set shellquote= shellxquote= ]])
    end
end
