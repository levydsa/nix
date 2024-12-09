--
-- simple neovim config
-- completely self contained
--

local autocmd = vim.api.nvim_create_autocmd

vim.opt.nu = true                        -- line numbers
vim.opt.rnu = true                       -- show line number relative to cursor line
vim.opt.redrawtime = 10000               -- more time to redraw (better for larger files)
vim.opt.cmdheight = 2                    -- larger command line
vim.opt.wrap = false                     -- no warping
vim.opt.wildmenu = true                  -- better completion menu
vim.opt.ignorecase = true                -- ignore case sensitive search
vim.opt.smartcase = true                 -- overwrite 'ignorecase' if search has upper case chars
vim.opt.hlsearch = true                  -- highlight search
vim.opt.updatetime = 300                 -- swap write to disk delay
vim.opt.signcolumn = 'yes:1'             -- automatic signs
vim.opt.colorcolumn = { 81 }             -- color column
vim.opt.encoding = 'utf-8'               -- utf-8 encoding
vim.opt.spelllang = { 'en_us', 'pt_br' } -- spell check English and Brazilian Portuguese
vim.opt.showtabline = 2                  -- always show the tab line

vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0

-- Show tabs and trailing spaces
vim.opt.listchars:append({ trail = "~", tab = "┃ ", space = "·" })
vim.opt.list = true

vim.opt.mouse = ""
autocmd("FileType", { pattern = { "*" }, command = [[setlocal fo-=cro]] })

-- who needs airline?
function Status()
    local spell = vim.opt.spell
    local langs = vim.opt.spelllang
    return ' %f %m%r%y '
        .. (spell:get() and '[' .. table.concat(langs:get(), ', ') .. ']' or '')
        .. '%=(%l, %c) (0x%B) (%P) [%L] '
end

vim.opt.statusline   = '%!v:lua.Status()'

-- don't keep or make backup
vim.opt.writebackup  = false
vim.opt.backup       = false

-- indentation
vim.opt.smartindent  = true
vim.opt.expandtab    = true -- don't expand tabs by default
vim.opt.shiftwidth   = 0    -- default to tabstop
vim.opt.tabstop      = 4    -- 4 spaces indent

vim.g.mapleader      = ' '  -- leader is space
vim.g.c_syntax_for_h = true -- don't know why the default is cpp :/

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y')
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p')
vim.keymap.set('n', '<leader>||', function()
    vim.api.nvim_open_win(0, false, {
        split = 'left',
        win = 0
    })
end)
vim.keymap.set('n', '<leader>__', function()
    vim.api.nvim_open_win(0, false, {
        split = 'above',
        win = 0
    })
end)

-- (s)et s(p)ell
vim.keymap.set('n', '<leader>sp', function()
    vim.opt.spell = not vim.opt.spell:get()
end)

vim.diagnostic.config {
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "?",
            [vim.diagnostic.severity.INFO]  = "",
        },
    },
}

-- custom indentation per filetype
local typecmd = {
    javascript = [[ setlocal ts=2 ]],
    typescript = [[ setlocal ts=2 ]],
    typescriptreact = [[ setlocal ts=2 ]],
    javascriptreact = [[ setlocal ts=2 ]],
    astro = [[ setlocal ts=2 ]],
    djot       = [[ setlocal ts=2 ]],
    nix        = [[ setlocal ts=2 ]],
    lean       = [[ setlocal ts=2 ]],
    sql        = [[ setlocal ts=2 ]],
    html       = [[ setlocal ts=2 ]],
    htmldjango = [[ setlocal ts=2 ]],
    tex        = [[ setlocal ts=2 ]],
    css        = [[ setlocal ts=2 ]],
    xml        = [[ setlocal ts=2 ]],
    sh         = [[ setlocal ts=2 ]],
    asm        = [[ setlocal ts=2 ]],
    elm        = [[ setlocal ts=2 ]],
    lua        = [[ setlocal ts=4 ]],
    go         = [[ setlocal ts=4 noet ]],
}

for filetype, cmd in pairs(typecmd) do
    autocmd("FileType", { pattern = { filetype }, command = cmd })
end

-- auto-save
autocmd({ "TextChanged", "InsertLeave" }, {
    pattern = { '*' },
    callback = function()
        if vim.fn.expand('%') ~= "" and not vim.bo.readonly and vim.bo then
            vim.cmd([[silent! update]])
        end
    end,
})

vim.filetype.add {
    extension = {
        templ = "templ",
        yuck = "lisp",
        djot = "djot",
        ["zig.zon"] = "zig",
    },
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    local lazyurl = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({
        "git", "clone", "--filter=blob:none", lazyurl, "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        opts = {},
        lazy = false,
        keys = {
            { '<leader>tt', [[ <cmd>ToggleTerm direction=float<cr> ]] },

            { '<esc>',      [[ <C-\><C-n> ]],                         mode = 't' },
            { '<C-h>',      [[ <cmd>wincmd h<cr> ]],                  mode = 't' },
            { '<C-j>',      [[ <cmd>wincmd j<cr> ]],                  mode = 't' },
            { '<C-k>',      [[ <cmd>wincmd k<cr> ]],                  mode = 't' },
            { '<C-l>',      [[ <cmd>wincmd l<cr> ]],                  mode = 't' },
            { '<C-q>',      [[ <C-\><C-n><C-w>q ]],                   mode = 't' },
        },
    },
    {
        "bluz71/vim-moonfly-colors",
        name = "moonfly",
        priority = 1000,
        config = function()
            vim.g.moonflyTransparent = true;
            vim.cmd.colorscheme("moonfly")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        main = "nvim-treesitter.configs",
        build = ":TSUpdate",
        opts = {
            ensure_installed = { "vimdoc", "lua", "markdown" },
            highlight = { enable = true },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        }
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/nvim-cmp",

            "onsails/lspkind.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",

            { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
            'saadparwaiz1/cmp_luasnip',

            "j-hui/fidget.nvim"
        },
        opts = {
            servers = {
                rust_analyzer = {
                    settings = {
                        imports = {
                            granularity = { group = "module" },
                            prefix = "self",
                        },
                        cargo = {
                            buildScripts = { enable = true },
                            loadOutDirsFromCheck = { enable = true },
                        },
                        procMacro = { enable = true },
                        -- diagnostics = { experimental = { enable = true } },
                        checkOnSave = { enable = false }
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = { globals = { 'vim', 'require' } },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                            },
                            telemetry = { enable = false },
                        },
                    },
                },
                clangd = {},
                jdtls = {},
                templ = {},
                phpactor = {},
                tsserver = {},
                gopls = {},
                zls = {},
                kotlin_language_server = {},
                nil_ls = {},
                html = { filetypes = { "html", "templ", "htmldjango" } },
                htmx = { filetypes = { "html", "templ", "htmldjango" } },
                tailwindcss = {},
                astro = {},
                solargraph = {},
            }
        },
        config = function(_, opts)
            local cmp = require('cmp')
            local lspconfig = require('lspconfig')
            local lspkind = require('lspkind');
            local fidget = require('fidget');

            vim.opt.completeopt = { "menu", "menuone", "noselect" }
            vim.opt.shortmess:append "c"
            vim.opt.signcolumn = 'yes'

            lspkind.init {}
            fidget.setup {}

            lspconfig.util.default_config.capabilities = vim.tbl_deep_extend(
                'force',
                lspconfig.util.default_config.capabilities,
                require('cmp_nvim_lsp').default_capabilities()
            )

            vim.api.nvim_create_autocmd('LspAttach', {
                desc = 'LSP actions',
                callback = function(event)
                    local opts = { buffer = event.buf }

                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("n", "<leader>gd", vim.lsp.buf.declaration, opts)
                    vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
                    vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, opts)
                    vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, opts)

                    vim.keymap.set("n", "<leader>g.", function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}), {})
                    end, opts)
                end,
            })

            for server, config in pairs(opts.servers) do
                lspconfig[server].setup(config)
            end

            cmp.setup({
                sources = cmp.config.sources({
                    { name = 'path' },
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                }),
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                }),
            })

            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end,
    },
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "-", "<cmd>Oil<cr>", { desc = "Open parent directory" } }
        },
        opts = {
            default_file_explorer = true,
            columns = { "icon" },
            keymaps = {
                ["<leader>ff"] = {
                    function()
                        require("telescope.builtin").find_files({
                            cwd = require("oil").get_current_dir()
                        })
                    end,
                    mode = "n",
                    nowait = true,
                    desc = "Find files in the current directory"
                },
                ["<leader>cd"] = {
                    "actions.cd",
                    opts = { silent = false },
                    desc = ":cd to the current directory"
                }
            },
        }
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "┃" },
            scope = { show_start = false, show_end = false },
        }
    },
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>fa", "<cmd>Telescope find_files hidden=true no_ignore=true<cr>" },
            { "<leader>ff", "<cmd>Telescope find_files<cr>" },
            { "<leader>fw", "<cmd>Telescope spell_suggest<cr>" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>" },
        },
        opts = {
            defaults = { layout_strategy = "vertical" },
        },
    },
    { "stevearc/dressing.nvim", event = "VeryLazy", },
    { 'vxpm/ferris.nvim',       opts = {} },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
            "ibhagwan/fzf-lua",
        },
        config = true
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
        end
    },
    {
        "davidmh/mdx.nvim",
        config = true,
        dependencies = { "nvim-treesitter/nvim-treesitter" }
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = { enable = true },
    },
    {
        "lewis6991/gitsigns.nvim",
        config = true,
    },
})
