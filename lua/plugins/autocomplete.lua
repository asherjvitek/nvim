return {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',

        -- Adds LSP completion capabilities
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-cmdline',

        -- Adds a number of user-friendly snippets
        'rafamadriz/friendly-snippets',
        'windwp/nvim-ts-autotag',
        'windwp/nvim-autopairs',
    },

    config = function()
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'

        require('luasnip.loaders.from_vscode').lazy_load()
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
        require('nvim-autopairs').setup({
            disable_filetype = { "TelescopePrompt", "vim" },
        })


        luasnip.config.setup {}

        local handlers = require('nvim-autopairs.completion.handlers')
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({
            filetypes = {
                ps1 = {
                    ['('] = {
                        kind = {
                            cmp.lsp.CompletionItemKind.Text,
                            --This does not appear to be working in powershell
                            --for some reason.... At least with C# methods...
                            cmp.lsp.CompletionItemKind.Method,
                        },
                        handler = handlers["*"]
                    }
                }
            }
        }))

        cmp.setup {
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            completion = {
                completeopt = 'menu,menuone,noinsert',
            },
            mapping = cmp.mapping.preset.insert {
                ['<C-a>'] = cmp.mapping.abort(),
                ['<C-n>'] = cmp.mapping.select_next_item(),
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete {},
                ['<C-y>'] = cmp.mapping.confirm {
                    select = true,
                },
                ['<C-l>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        luasnip.jump(1)
                    elseif luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<C-h>'] = cmp.mapping(function(fallback)
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            },
            sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'path' },
                { name = 'nvim_lsp_signature_help' },
                { name = 'buffer' },
                { name = "vim-dadbod-completion" },
            },
            experimental = {
                ghost_text = true,
            },
        }

        --This gives me complete from inside the current buffer in the commandline
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

        --This gives completion from the file path in the commandline of nvim.
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                {
                    name = 'cmdline',
                    option = {
                        ignore_cmds = { 'Man', '!' }
                    }
                }
            })
        })
    end
}
