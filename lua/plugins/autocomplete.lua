return {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = {
        'rafamadriz/friendly-snippets',
    },

    -- use a release tag to download pre-built binaries
    version = '*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        -- 'default' for mappings similar to built-in completion
        -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
        -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
        -- See the full "keymap" documentation for information on defining your own keymap.
        keymap = {
            preset = 'none',
            ['<C-d>'] = { 'show', 'show_documentation', 'hide_documentation' },

            ['<C-e>'] = { 'show', 'hide' },
            ['<C-y>'] = { 'select_and_accept' },

            --Maybe change back to tab for things
            ['<C-l>'] = { 'snippet_forward', 'fallback' },
            ['<C-h>'] = { 'snippet_backward', 'fallback' },

            ['<Tab>'] = {
                function(cmp)
                    if cmp.snippet_active() then
                        return cmp.accept()
                    else
                        return cmp.select_and_accept()
                    end
                end,
                'snippet_forward',
                'fallback'
            },
            ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

            ['<C-s>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },

            --removed Up and Down from this because that means that you can't type then use Up to go to the last in the history
            ['<C-p>'] = { 'select_prev', 'fallback' },
            ['<C-n>'] = { 'select_next', 'fallback' },

            ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

            ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
        },

        completion = {
            accept = {
                auto_brackets = {
                    enabled = true,
                },
            },
        },


        cmdline = {
            completion = {
                menu = {
                    auto_show = true,
                }
            },
        },

        appearance = {
            -- Sets the fallback highlight groups to nvim-cmp's highlight groups
            -- Useful for when your theme doesn't support blink.cmp
            -- Will be removed in a future release
            use_nvim_cmp_as_default = true,
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono'
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
            per_filetype = {
                sql = { 'snippets', 'dadbod', 'buffer' },
            },
            -- add vim-dadbod-completion to your completion providers
            providers = {
                dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                lazydev = {
                    name = 'lazyDev',
                    module = 'lazydev.integrations.blink',
                    score_offset = 100,
                }
            },
        },

        signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
}
