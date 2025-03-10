local plugin_dir = vim.fs.normalize("~/repo/asp-monkey.nvim/")

local fd, _, _ = vim.uv.fs_open(plugin_dir, "r", 438)

if fd == nil then
    return {}
end

return {
    dir = plugin_dir
}
