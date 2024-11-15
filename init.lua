-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
    -- NOTE: First, some plugins that don't require any configuration

    -- Git related plugins
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    'tpope/vim-dadbod',
    'kristijanhusak/vim-dadbod-completion',
    'kristijanhusak/vim-dadbod-ui',
    'stevearc/oil.nvim',

    -- Detect tabstop and shiftwidth automatically
    -- 'tpope/vim-sleuth',

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            {
                'williamboman/mason.nvim',
                config = true
            },
            'williamboman/mason-lspconfig.nvim',
            {
                'j-hui/fidget.nvim',
                opts = {}
            },

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
        },
    },

    {
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
    },

    -- Useful plugin to show you pending keybinds.
    {
        'folke/which-key.nvim',
        opts = {},
        config = function()
            -- document existing key chains
            require('which-key').add
            {
                { "<leader>c",  group = "[C]ode" },
                { "<leader>c_", hidden = true },
                { "<leader>d",  group = "[D]ocument" },
                { "<leader>d_", hidden = true },
                { "<leader>g",  group = "[G]it" },
                { "<leader>g_", hidden = true },
                { "<leader>h",  group = "Git [H]unk" },
                { "<leader>h_", hidden = true },
                { "<leader>r",  group = "[R]ename" },
                { "<leader>r_", hidden = true },
                { "<leader>s",  group = "[S]earch" },
                { "<leader>s_", hidden = true },
                { "<leader>t",  group = "[T]oggle" },
                { "<leader>t_", hidden = true },
                { "<leader>w",  group = "[W]orkspace" },
                { "<leader>w_", hidden = true },
            }
            -- register which-key VISUAL mode
            -- required for visual <leader>hs (hunk stage) to work
            require('which-key').add(
                {
                    { "<leader>",  group = "VISUAL <leader>", mode = "v" },
                    { "<leader>h", desc = "Git [H]unk",       mode = "v" },
                }
                , { mode = 'v' })
        end
    },
    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map({ 'n', 'v' }, ']c', function()
                    if vim.wo.diff then
                        return ']c'
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return '<Ignore>'
                end, { expr = true, desc = 'Jump to next hunk' })

                map({ 'n', 'v' }, '[c', function()
                    if vim.wo.diff then
                        return '[c'
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return '<Ignore>'
                end, { expr = true, desc = 'Jump to previous hunk' })

                -- Actions
                -- visual mode
                map('v', '<leader>hs', function()
                    gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
                end, { desc = 'stage git hunk' })
                map('v', '<leader>hr', function()
                    gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
                end, { desc = 'reset git hunk' })
                -- normal mode
                map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
                map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
                map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
                map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
                map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
                map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
                map('n', '<leader>hb', function()
                    gs.blame_line { full = false }
                end, { desc = 'git blame line' })
                map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
                map('n', '<leader>hD', function()
                    gs.diffthis '~'
                end, { desc = 'git diff against last commit' })

                -- Toggles
                map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
                map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

                -- Text object
                map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
            end,
        },
    },
    {
        'folke/tokyonight.nvim',
        -- priority = 1000,
        -- config = function()
        --     vim.cmd.colorscheme 'tokyonight-night'
        -- end,
    },

    {
        'Mofiqul/vscode.nvim',
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'vscode'
        end,
    },

    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                icons_enabled = false,
                theme = 'onedark',
                component_separators = '|',
                section_separators = '',
            },
        },
    },

    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help ibl`
        main = 'ibl',
        opts = {},
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
        config = function()
            -- [[ Configure Telescope ]]
            -- See `:help telescope` and `:help telescope.setup()`
            require('telescope').setup {
                defaults = {
                    layout_config = {
                        horizontal = { width = .95, height = .99 }
                    },
                    mappings = {
                        i = {
                            ['<C-u>'] = false,
                            ['<C-d>'] = false,
                        },
                    },
                }
            }

            -- Enable telescope fzf native, if installed
            pcall(require('telescope').load_extension, 'fzf')

            -- Telescope live_grep in git root
            -- Function to find the git root directory based on the current buffer's path
            local function find_git_root()
                -- Use the current buffer's path as the starting point for the git search
                local current_file = vim.api.nvim_buf_get_name(0)
                local current_dir
                local cwd = vim.fn.getcwd()
                -- If the buffer is not associated with a file, return nil
                if current_file == '' then
                    current_dir = cwd
                else
                    -- Extract the directory from the current file's path
                    current_dir = vim.fn.fnamemodify(current_file, ':h')
                end

                -- Find the Git root directory from the current file's path
                local git_root = vim.fn.systemlist('git -C ' ..
                    vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
                if vim.v.shell_error ~= 0 then
                    print 'Not a git repository. Searching on current working directory'
                    return cwd
                end
                return git_root
            end

            -- Custom live_grep function to search in git root
            local function live_grep_git_root()
                local git_root = find_git_root()
                if git_root then
                    require('telescope.builtin').live_grep {
                        search_dirs = { git_root },
                    }
                end
            end

            vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

            -- See `:help telescope.builtin`
            vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles,
                { desc = '[?] Find recently opened files' })
            vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers,
                { desc = '[ ] Find existing buffers' })
            vim.keymap.set('n', '<leader>/', function()
                -- You can pass additional configuration to telescope to change theme, layout, etc.
                require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                })
            end, { desc = '[/] Fuzzily search in current buffer' })

            local function telescope_live_grep_open_files()
                require('telescope.builtin').live_grep {
                    grep_open_files = true,
                    prompt_title = 'Live Grep in Open Files',
                }
            end
            vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
            vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin,
                { desc = '[S]earch [S]elect Telescope' })
            vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
            vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
            vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
            vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string,
                { desc = '[S]earch current [W]ord' })
            vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
            vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
            vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics,
                { desc = '[S]earch [D]iagnostics' })
            vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
        end
    },

    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        build = ':TSUpdate',
    },

    --This is what will illumiate the text that you cursor is currently on top of like what you get in VS or VSCode.
    'RRethy/vim-illuminate',
    --This gives you a nice little left pane visual of the undotree.
    'mbbill/undotree',
    --This lets you "Harpoon" files for fast access
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local harpoon = require("harpoon")

            harpoon:setup({})

            vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = '[H]arpoon [A]dd' })
            vim.keymap.set("n", "<leader>ho", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
                { desc = '[H]arpoon [O]pen' })

            vim.keymap.set("n", "<M-j>", function() harpoon:list():select(1) end, { desc = 'Harpoon Item 1' })
            vim.keymap.set("n", "<M-k>", function() harpoon:list():select(2) end, { desc = 'Harpoon Item 2' })
            vim.keymap.set("n", "<M-l>", function() harpoon:list():select(3) end, { desc = 'Harpoon Item 3' })
            vim.keymap.set("n", "<M-;>", function() harpoon:list():select(4) end, { desc = 'Harpoon Item 4' })

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<M-n>", function() harpoon:list():next() end, { desc = '[H]arpoon [N]ext' })
            vim.keymap.set("n", "<M-p>", function() harpoon:list():prev() end, { desc = '[H]arpoon [P]revious' })
        end
    },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            focus = true
        },
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)"
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        }
    }
}, {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤 ',
        },
    },
})

-- [[ Setting options ]]

-- Set highlight on search
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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

--If we have powershell then we are on windows and would like to use that for our shell.
if vim.fn.executable('powershell') == 1 then
    --Make it so that powershell is the default sheel that is used.
    vim.o.shell = 'powershell'
    vim.o.shellcmdflag =
    "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
    vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    vim.o.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'

    --I have not translated this because I could not figure out how to make these work.
    vim.cmd([[ set shellquote= shellxquote= ]])
end

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

local copy_buffer_path = function()
    local path = vim.fn.expand("%:p")
    path = path:gsub("/", "\\")
    vim.fn.setreg('+', path)
    print(path, "copied to register")
end

vim.keymap.set("n", "<leader>yp", copy_buffer_path, { desc = "[Y]ank Current Buffer [P]ath" })
-- vim.keymap.set('n', '<leader>j', vim.cmd.Ex, { desc = ':Ex' })
vim.keymap.set("n", "<leader>j", "<CMD>Oil<CR>", { desc = "Open parent directory" })

--I think that this would likely make some people really mad....
vim.keymap.set({ "i", "c" }, "<C-H>", "<C-W>", { desc = "CTRL Backspace works like it does other places" })
-- I would like to stop using this one so I am going to comment it out for now and make myself use :w more.
-- Or maybe I would like a save all buffers or something.
-- vim.keymap.set("n", "<C-S>", vim.cmd.w, { desc = "[S]ave File" })

--This works in VS but I could not get J or K with this map to work there so we have this.
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move text up" })
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move text down" })
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move text up" })

vim.keymap.set("n", "<leader>rt", ":%s/\t/    /g<CR>")


--End of the hate

-- Window maps
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '+', '<C-w>+', { desc = 'Increae Split Height' })
vim.keymap.set('n', '-', '<C-w>-', { desc = 'Decrease Split Height' })

--Navigation quality of life
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Half page down keep center' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Half page up keep center' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next keep center' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous keep center' })

--Maniplulation into the void register instead of the default
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = '[D]elete into void register' })
vim.keymap.set({ "n", "v" }, "<leader>c", [["_c]], { desc = '[C]hange into void register' })

vim.keymap.set("n", "<leader>sc", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = '[S]ubstitute [C]urrent word' })
vim.keymap.set("v", "<leader>sc", [[y :%s/<C-r>"/<C-r>"/gI<Left><Left><Left>]], { desc = '[S]ubstitute [C]urrent word' })

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = '[E]xit Terminal Insert Mode' })

vim.api.nvim_create_user_command('FormatRuleXml', '%s/&lt;/</g | %s/&gt;/>/g', { desc = 'Format Rule Xml' })

vim.api.nvim_create_user_command('FormatElmahError', '%s/&#xD;&#xA;/\r/g', { desc = 'Format Elmah Error' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
    require('nvim-treesitter.configs').setup {
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = {
            'c',
            'cpp',
            'lua',
            'javascript',
            'vimdoc',
            'vim',
            'bash',
            'c_sharp',
            'xml',
            'json',
            'css',
            'html',
            'sql'
        },

        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = false,
        -- Install languages synchronously (only applied to `ensure_installed`)
        sync_install = false,
        -- List of parsers to ignore installing
        ignore_install = {},
        -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
        modules = {},
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = '<c-space>',
                node_incremental = '<c-space>',
                scope_incremental = '<c-s>',
                node_decremental = '<M-space>',
            },
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ['aa'] = '@parameter.outer',
                    ['ia'] = '@parameter.inner',
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
                },
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    [']m'] = '@function.outer',
                    [']]'] = '@class.outer',
                },
                goto_next_end = {
                    [']M'] = '@function.outer',
                    [']['] = '@class.outer',
                },
                goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[['] = '@class.outer',
                },
                goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[]'] = '@class.outer',
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ['<leader>a'] = '@parameter.inner',
                },
                swap_previous = {
                    ['<leader>A'] = '@parameter.inner',
                },
            },
        },
    }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>.', vim.lsp.buf.code_action, '[C]ode [A]ction')
    vim.keymap.set('v', '<leader>.', vim.lsp.buf.code_action, { buffer = bufnr, desc = 'LSP: [C]ode [A]ction' })

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })

    vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = '[F]ormat current buffer with LSP' })
end

require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}

-- if vim.fn.executable('node') == 1 then
--     servers.tsserver = {
--         implicitProjectConfiguration = {
--             checkJs = true
--         },
--     }
-- end

if vim.fn.executable('powershell') == 1 then
    servers.powershell_es = {
        shell = "powershell",
    }
end

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup({
            shell = (servers[server_name] or {}).shell,
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        })
    end,
}

require('oil').setup({
    skip_confirm_for_simple_edits = true,
    view_options = {
        show_hidden = true,
    }
});
