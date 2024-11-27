--work commands for things that I run into from time to time.
local function format_rule_xml()
    vim.cmd('%s/&lt;/</g | %s/&gt;/>/g')
    vim.lsp.buf.format()
end

vim.api.nvim_create_user_command('FormatRuleXml', format_rule_xml, { desc = 'Format Rule Xml' })
vim.api.nvim_create_user_command('FormatElmahError', '%s/&#xD;&#xA;/\r/g', { desc = 'Format Elmah Error' })

if pcall(require, "aspmonkey") then
    vim.api.nvim_create_user_command('AspMonkey', require("aspmonkey").asp_monkey,
        { desc = 'Monkey me some ASP into one big file.' })
end
