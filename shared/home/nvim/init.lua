--
-- simple neovim config
-- completely self contained

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
vim.opt.colorcolumn = "+1"               -- color column
vim.opt.encoding = 'utf-8'               -- utf-8 encoding
vim.opt.spelllang = { 'en_us', 'pt_br' } -- spell check English and Brazilian Portuguese
vim.opt.showtabline = 2                  -- always show the tab line
vim.opt.autowriteall = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append "c"
vim.opt.signcolumn = 'yes'

vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0

-- Show tabs and trailing spaces
vim.opt.listchars:append({ trail = "~", tab = "┃ ", space = "·" })
vim.opt.list = true

vim.opt.mouse = ""
autocmd("FileType", { pattern = { "*" }, command = [[setlocal fo-=cro]] })

-- auto-save
autocmd({ "TextChanged", "InsertLeave" }, {
    pattern = { '*' },
    callback = function()
        if vim.fn.expand('%') ~= "" and not vim.bo.readonly and vim.bo then
            vim.cmd([[silent! update]])
        end
    end,
})

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

local open_window    = function(split)
    return function()
        vim.api.nvim_open_win(0, false, { split = split, win = 0 })
    end
end

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y')
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p')
vim.keymap.set('n', '<leader>|', open_window("left"))
vim.keymap.set('n', '<leader>_', open_window("above"))

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

vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
        })
    end
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
local lazyurl = "https://github.com/folke/lazy.nvim.git"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none", lazyurl, "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
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
            auto_install = true,

            -- TODO: Figure out how to use incremental selection
        },
        config = function(_, opts)
            require 'nvim-treesitter.configs'.setup(opts)

            local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
            parser_config.blade = {
                install_info = {
                    url = "https://github.com/EmranMR/tree-sitter-blade",
                    files = { "src/parser.c" },
                    branch = "main",
                },
                filetype = "blade"
            }
        end
    },
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        config = true
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "f3fora/cmp-spell",

            { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
            'saadparwaiz1/cmp_luasnip',
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                snippet = {
                    expand = function(args) vim.snippet.expand(args.body) end,
                },
                sources = {
                    { name = 'path' },
                    { name = 'nvim_lsp' },
                    { name = 'luasnips' },
                    { name = 'buffer' },
                    { name = 'spell' },
                },
            })

            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' },
                }
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'path' },
                    { name = 'cmdline' },
                }
            })
        end
    },
    {
        "onsails/lspkind.nvim",
        config = function() require('lspkind').init {} end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
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
                    checkOnSave = { enable = true },
                    diagnostics = { experimental = { enable = true } },
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
            zls = {
                zls = {
                    enable_snippets = true,
                    enable_ast_check_diagnostics = true,
                    enable_autofix = true,
                    enable_import_embedfile_argument_completions = true,
                    warn_style = true,
                    enable_semantic_tokens = true,
                    enable_inlay_hints = true,
                    inlay_hints_hide_redundant_param_names = true,
                    inlay_hints_hide_redundant_param_names_last_token = true,
                    operator_completions = true,
                    include_at_in_builtins = true,
                    max_detail_length = 1048576,
                },
            },
            kotlin_language_server = {},
            nil_ls = {},
            html = { filetypes = { "html", "templ", "htmldjango" } },
            htmx = { filetypes = { "html", "templ", "htmldjango" } },
            tailwindcss = {},
            astro = {},
            solargraph = {},
            gleam = {},
        },
        config = function(_, opts)
            local lspconfig = require('lspconfig')

            for server, config in pairs(opts) do
                lspconfig[server].setup(config)
            end

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
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                    end, opts)
                end,
            })
        end,
    },
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "-", "<cmd>Oil<cr>", desc = "Open parent directory" }
        },
        opts = {
            default_file_explorer = true,
            columns = { "icon" },
            keymaps = {
                ["<leader>fg"] = {
                    function()
                        require("telescope.builtin").live_grep({
                            cwd = require("oil").get_current_dir()
                        })
                    end,
                    mode = "n",
                    nowait = true,
                    desc = "Find files in the current directory"
                },
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
            {
                "<leader>fa",
                "<cmd>Telescope find_files hidden=true no_ignore=true<cr>",
                desc = "(F)ind (a)ll files"
            },
            {
                "<leader>ff",
                "<cmd>Telescope find_files<cr>",
                desc = "(F)ind (f)iles"
            },
            {
                "<leader>fs",
                "<cmd>Telescope spell_suggest<cr>",
                desc = "(F)ind (s)pell"
            },
            {
                "<leader>fg",
                "<cmd>Telescope live_grep<cr>",
                desc = "(F)ind (g)rep"
            },
            {
                "<leader>fh",
                "<cmd>Telescope help_tags<cr>",
                desc = "(F)ind (h)elp"
            },
        },
        opts = { defaults = { layout_strategy = "vertical" } },
    },
    {
        "NeogitOrg/neogit",
        cmd = "Neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
            "ibhagwan/fzf-lua",
        },
        config = true
    },
    {
        "davidmh/mdx.nvim",
        config = true,
        dependencies = { "nvim-treesitter/nvim-treesitter" }
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = true,
    },
    {
        'nmac427/guess-indent.nvim',
        config = true,
    },
    {
        "lewis6991/gitsigns.nvim",
        config = true,
    },
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        config = true,
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            sections = {
                lualine_c = {
                    'filename',
                    function()
                        if vim.wo.spell then
                            return '[' .. vim.bo.spelllang .. ']'
                        else
                            return ''
                        end
                    end
                }
            }
        },
        init = function()
            vim.opt.showmode = false
        end
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        main = "nvim-treesitter.configs",
        opts = {
            textobjects = {
                swap = {
                    enable = true,
                    swap_next = { ["<leader>a"] = "@parameter.inner", },
                    swap_previous = { ["<leader>A"] = "@parameter.inner", },
                },
            },
        },
    },
})
