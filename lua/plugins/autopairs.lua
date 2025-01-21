--I would like to get this working like it used to with the other autocomplete pulgin but I am not sure if blink has an event for when the accept i done
return {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = function()
        require('nvim-autopairs').setup({
            disable_filetype = { "TelescopePrompt", "vim" },
        })
    end,
}
