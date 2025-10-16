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
vim.opt.colorcolumn = "+1"               -- color column
vim.opt.encoding = 'utf-8'               -- utf-8 encoding
vim.opt.spelllang = { 'en_us', 'pt_br' } -- spell check English and Brazilian Portuguese
vim.opt.showtabline = 2                  -- always show the tab line
vim.opt.autowriteall = true
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }
vim.opt.shortmess:append "c"
vim.opt.signcolumn = 'yes'
vim.opt.showmode = false

vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0

-- Show tabs and trailing spaces
vim.opt.listchars:append({ trail = "~", tab = "┃ " })
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

vim.diagnostic.config({
    virtual_text = true,      -- Show errors inline (disabled by default in 0.11)
    signs = true,             -- Show signs in gutter
    underline = true,         -- Underline errors
    update_in_insert = false, -- Don't update diagnostics while typing
    severity_sort = true,     -- Sort by severity
    float = {
        border = 'rounded',
        header = '',
        prefix = '',
    },
})

vim.filetype.add {
    extension = {
        templ = "templ",
        yuck = "lisp",
        djot = "djot",
        ["zig.zon"] = "zig",
    },
}

vim.pack.add {
    'https://github.com/nuvic/flexoki-nvim',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/j-hui/fidget.nvim',
    'https://github.com/stevearc/oil.nvim',
    'https://github.com/f-person/auto-dark-mode.nvim',
    'https://github.com/echasnovski/mini.pick',
    'https://github.com/nvim-lualine/lualine.nvim',
    'https://github.com/lewis6991/gitsigns.nvim',
    'https://github.com/lukas-reineke/indent-blankline.nvim',

    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/mason-org/mason-lspconfig.nvim',
    'https://github.com/mason-org/mason.nvim',
    'https://github.com/saghen/blink.cmp',
    'https://github.com/linrongbin16/gitlinker.nvim',
}

vim.cmd.colorscheme("flexoki")

local pick = require('mini.pick')
local lualine = require('lualine')
local fidget = require('fidget')
local oil = require('oil')

require('nvim-treesitter.configs').setup {
    ensure_installed = { "vim", "lua", "vimdoc", "markdown", "markdown_inline" },
    sync_install = false,
    auto_install = true,
    ignore_install = {},
    modules = {},
    highlight = { enable = true },
    additional_vim_regex_highlighting = false,
}

require('ibl').setup {}
require('auto-dark-mode').setup {}
require('gitsigns').setup { current_line_blame = true }

pick.setup {}
vim.keymap.set("n", "gf", pick.builtin.grep_live, {})

lualine.setup {
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
}

fidget.setup {}

require('blink.cmp').setup {
    keymap = {
        preset = 'super-tab',
    },
    completion = {
        trigger = {
            show_in_snippet = false,
        },
    },
}

require('mason').setup {}
require('mason-lspconfig').setup { automatic_enable = true }

oil.setup {
    default_file_explorer = true,
    columns = { "icon" },
    keymaps = {},
}

require('gitlinker').setup()
vim.keymap.set({ "n", 'v' }, "gy", "<cmd>GitLink<cr>")

vim.keymap.set('n', '-', oil.open)

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(args)
        local opts = { buffer = args.buf }

        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "g.", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gu", vim.lsp.buf.incoming_calls, opts)
        vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
    end,
})

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" }, },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = { enable = false },
        },
    }
})

vim.lsp.config('zls', {
    settings = {
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
        }
    }
})

local bevy_root = "file:///Users/levy/Documents/bevy";

vim.lsp.config('wgsl_analyzer', {
    settings = {
        ["wgsl-analyzer"] = {
            shaderDefs = {
                "VERTEX_TANGENTS",
                "VERTEX_NORMALS",
                "VERTEX_COLORS",
                "VERTEX_UVS",
                "SKINNED",
            },
            inlayHints = {
                enabled = true,
                typeHints = true,
                parameterHints = true,
                structLayoutHints = true,
            },
            customImports = {
                ["bevy_pbr::clustered_forward"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/clustered_forward.wgsl",
                ["bevy_pbr::mesh_bindings"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/mesh_bindings.wgsl",
                ["bevy_pbr::mesh_functions"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/mesh_functions.wgsl",
                ["bevy_pbr::mesh_types"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/mesh_types.wgsl",
                ["bevy_pbr::mesh_vertex_output"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/mesh_vertex_output.wgsl",
                ["bevy_pbr::mesh_view_bindings"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/mesh_view_bindings.wgsl",
                ["bevy_pbr::mesh_view_types"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/mesh_view_types.wgsl",
                ["bevy_pbr::pbr_bindings"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/pbr_bindings.wgsl",
                ["bevy_pbr::pbr_functions"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/pbr_functions.wgsl",
                ["bevy_pbr::lighting"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/pbr_lighting.wgsl",
                ["bevy_pbr::pbr_types"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/pbr_types.wgsl",
                ["bevy_pbr::shadows"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/shadows.wgsl",
                ["bevy_pbr::skinning"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/skinning.wgsl",
                ["bevy_pbr::utils"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_pbr/src/render/utils.wgsl",
                ["bevy_sprite::mesh2d_bindings"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_sprite/src/mesh2d/mesh2d_bindings.wgsl",
                ["bevy_sprite::mesh2d_functions"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_sprite/src/mesh2d/mesh2d_functions.wgsl",
                ["bevy_sprite::mesh2d_types"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_sprite/src/mesh2d/mesh2d_types.wgsl",
                ["bevy_sprite::mesh2d_vertex_output"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_sprite/src/mesh2d/mesh2d_vertex_output.wgsl",
                ["bevy_sprite::mesh2d_view_bindings"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_sprite/src/mesh2d/mesh2d_view_bindings.wgsl",
                ["bevy_sprite::mesh2d_view_types"] =
                "https://raw.githubusercontent.com/bevyengine/bevy/v0.10.0/crates/bevy_sprite/src/mesh2d/mesh2d_view_types.wgsl",
            },
        },
        -- ['wgsl-analyzer'] = {
        --     inlayHints = {
        --         enabled = true,
        --         typeHints = true,
        --         parameterHints = true,
        --         structLayoutHints = true,
        --     },
        --     customImports = {
        --         ["bevy_core_pipeline::fullscreen_vertex_shader"] = bevy_root ..
        --         "crates/bevy_core_pipeline/src/fullscreen_vertex_shader/fullscreen.wgsl",
        --         ["bevy_core_pipeline::oit"] = bevy_root .. "crates/bevy_core_pipeline/src/oit/oit_draw.wgsl",
        --         ["bevy_core_pipeline::tonemapping_lut_bindings"] = bevy_root ..
        --         "crates/bevy_core_pipeline/src/tonemapping/lut_bindings.wgsl",
        --         ["bevy_core_pipeline::tonemapping"] = bevy_root ..
        --         "crates/bevy_core_pipeline/src/tonemapping/tonemapping_shared.wgsl",
        --         ["bevy_pbr::atmosphere::bindings"] = bevy_root .. "crates/bevy_pbr/src/atmosphere/bindings.wgsl",
        --         ["bevy_pbr::atmosphere::bruneton_functions"] = bevy_root ..
        --         "crates/bevy_pbr/src/atmosphere/bruneton_functions.wgsl",
        --         ["bevy_pbr::atmosphere::functions"] = bevy_root .. "crates/bevy_pbr/src/atmosphere/functions.wgsl",
        --         ["bevy_pbr::atmosphere::types"] = bevy_root .. "crates/bevy_pbr/src/atmosphere/types.wgsl",
        --         ["bevy_pbr::decal::clustered"] = bevy_root .. "crates/bevy_pbr/src/decal/clustered.wgsl",
        --         ["bevy_pbr::decal::forward"] = bevy_root .. "crates/bevy_pbr/src/decal/forward_decal.wgsl",
        --         ["bevy_pbr::pbr_deferred_functions"] = bevy_root ..
        --         "crates/bevy_pbr/src/deferred/pbr_deferred_functions.wgsl",
        --         ["bevy_pbr::pbr_deferred_types"] = bevy_root .. "crates/bevy_pbr/src/deferred/pbr_deferred_types.wgsl",
        --         ["bevy_pbr::environment_map"] = bevy_root .. "crates/bevy_pbr/src/light_probe/environment_map.wgsl",
        --         ["bevy_pbr::irradiance_volume"] = bevy_root .. "crates/bevy_pbr/src/light_probe/irradiance_volume.wgsl",
        --         ["bevy_pbr::light_probe"] = bevy_root .. "crates/bevy_pbr/src/light_probe/light_probe.wgsl",
        --         ["bevy_pbr::lightmap"] = bevy_root .. "crates/bevy_pbr/src/lightmap/lightmap.wgsl",
        --         ["bevy_pbr::meshlet_bindings"] = bevy_root .. "crates/bevy_pbr/src/meshlet/meshlet_bindings.wgsl",
        --         ["bevy_pbr::meshlet_cull_shared"] = bevy_root .. "crates/bevy_pbr/src/meshlet/meshlet_cull_shared.wgsl",
        --         ["bevy_pbr::meshlet_visibility_buffer_resolve"] = bevy_root ..
        --         "crates/bevy_pbr/src/meshlet/visibility_buffer_resolve.wgsl",
        --         ["bevy_pbr::prepass_bindings"] = bevy_root .. "crates/bevy_pbr/src/prepass/prepass_bindings.wgsl",
        --         ["bevy_pbr::prepass_io"] = bevy_root .. "crates/bevy_pbr/src/prepass/prepass_io.wgsl",
        --         ["bevy_pbr::prepass_utils"] = bevy_root .. "crates/bevy_pbr/src/prepass/prepass_utils.wgsl",
        --         ["bevy_pbr::clustered_forward"] = bevy_root .. "crates/bevy_pbr/src/render/clustered_forward.wgsl",
        --         ["bevy_pbr::fog"] = bevy_root .. "crates/bevy_pbr/src/render/fog.wgsl",
        --         ["bevy_pbr::forward_io"] = bevy_root .. "crates/bevy_pbr/src/render/forward_io.wgsl",
        --         ["bevy_pbr::mesh_bindings"] = bevy_root .. "crates/bevy_pbr/src/render/mesh_bindings.wgsl",
        --         ["bevy_pbr::mesh_functions"] = bevy_root .. "crates/bevy_pbr/src/render/mesh_functions.wgsl",
        --         ["bevy_pbr::mesh_types"] = bevy_root .. "crates/bevy_pbr/src/render/mesh_types.wgsl",
        --         ["bevy_pbr::mesh_view_bindings"] = bevy_root .. "crates/bevy_pbr/src/render/mesh_view_bindings.wgsl",
        --         ["bevy_pbr::mesh_view_types"] = bevy_root .. "crates/bevy_pbr/src/render/mesh_view_types.wgsl",
        --         ["bevy_pbr::morph"] = bevy_root .. "crates/bevy_pbr/src/render/morph.wgsl",
        --         ["bevy_pbr::occlusion_culling"] = bevy_root .. "crates/bevy_pbr/src/render/occlusion_culling.wgsl",
        --         ["bevy_pbr::parallax_mapping"] = bevy_root .. "crates/bevy_pbr/src/render/parallax_mapping.wgsl",
        --         ["bevy_pbr::ambient"] = bevy_root .. "crates/bevy_pbr/src/render/pbr_ambient.wgsl",
        --         ["bevy_pbr::pbr_bindings"] = bevy_root .. "crates/bevy_pbr/src/render/pbr_bindings.wgsl",
        --         ["bevy_pbr::pbr_fragment"] = bevy_root .. "crates/bevy_pbr/src/render/pbr_fragment.wgsl",
        --         ["bevy_pbr::pbr_functions"] = bevy_root .. "crates/bevy_pbr/src/render/pbr_functions.wgsl",
        --         ["bevy_pbr::lighting"] = bevy_root .. "crates/bevy_pbr/src/render/pbr_lighting.wgsl",
        --         ["bevy_pbr::pbr_prepass_functions"] = bevy_root ..
        --         "crates/bevy_pbr/src/render/pbr_prepass_functions.wgsl",
        --         ["bevy_pbr::transmission"] = bevy_root .. "crates/bevy_pbr/src/render/pbr_transmission.wgsl",
        --         ["bevy_pbr::pbr_types"] = bevy_root .. "crates/bevy_pbr/src/render/pbr_types.wgsl",
        --         ["bevy_pbr::rgb9e5"] = bevy_root .. "crates/bevy_pbr/src/render/rgb9e5.wgsl",
        --         ["bevy_pbr::shadow_sampling"] = bevy_root .. "crates/bevy_pbr/src/render/shadow_sampling.wgsl",
        --         ["bevy_pbr::shadows"] = bevy_root .. "crates/bevy_pbr/src/render/shadows.wgsl",
        --         ["bevy_pbr::skinning"] = bevy_root .. "crates/bevy_pbr/src/render/skinning.wgsl",
        --         ["bevy_pbr::utils"] = bevy_root .. "crates/bevy_pbr/src/render/utils.wgsl",
        --         ["bevy_pbr::view_transformations"] = bevy_root .. "crates/bevy_pbr/src/render/view_transformations.wgsl",
        --         ["bevy_pbr::ssao_utils"] = bevy_root .. "crates/bevy_pbr/src/ssao/ssao_utils.wgsl",
        --         ["bevy_pbr::raymarch"] = bevy_root .. "crates/bevy_pbr/src/ssr/raymarch.wgsl",
        --         ["bevy_pbr::ssr"] = bevy_root .. "crates/bevy_pbr/src/ssr/ssr.wgsl",
        --         ["bevy_core_pipeline::post_processing::chromatic_aberration"] = bevy_root ..
        --         "crates/bevy_post_process/src/effect_stack/chromatic_aberration.wgsl",
        --         ["bevy_render::bindless"] = bevy_root .. "crates/bevy_render/src/bindless.wgsl",
        --         ["bevy_render::color_operations"] = bevy_root .. "crates/bevy_render/src/color_operations.wgsl",
        --         ["bevy_pbr::mesh_preprocess_types"] = bevy_root ..
        --         "crates/bevy_render/src/experimental/occlusion_culling/mesh_preprocess_types.wgsl",
        --         ["bevy_render::globals"] = bevy_root .. "crates/bevy_render/src/globals.wgsl",
        --         ["bevy_render::maths"] = bevy_root .. "crates/bevy_render/src/maths.wgsl",
        --         ["bevy_render::view"] = bevy_root .. "crates/bevy_render/src/view/view.wgsl",
        --         ["bevy_solari::gbuffer_utils"] = bevy_root .. "crates/bevy_solari/src/realtime/gbuffer_utils.wgsl",
        --         ["bevy_solari::presample_light_tiles"] = bevy_root ..
        --         "crates/bevy_solari/src/realtime/presample_light_tiles.wgsl",
        --         ["bevy_solari::world_cache"] = bevy_root .. "crates/bevy_solari/src/realtime/world_cache_query.wgsl",
        --         ["bevy_solari::brdf"] = bevy_root .. "crates/bevy_solari/src/scene/brdf.wgsl",
        --         ["bevy_solari::scene_bindings"] = bevy_root ..
        --         "crates/bevy_solari/src/scene/raytracing_scene_bindings.wgsl",
        --         ["bevy_solari::sampling"] = bevy_root .. "crates/bevy_solari/src/scene/sampling.wgsl",
        --         ["bevy_sprite::mesh2d_bindings"] = bevy_root ..
        --         "crates/bevy_sprite_render/src/mesh2d/mesh2d_bindings.wgsl",
        --         ["bevy_sprite::mesh2d_functions"] = bevy_root ..
        --         "crates/bevy_sprite_render/src/mesh2d/mesh2d_functions.wgsl",
        --         ["bevy_sprite::mesh2d_types"] = bevy_root .. "crates/bevy_sprite_render/src/mesh2d/mesh2d_types.wgsl",
        --         ["bevy_sprite::mesh2d_vertex_output"] = bevy_root ..
        --         "crates/bevy_sprite_render/src/mesh2d/mesh2d_vertex_output.wgsl",
        --         ["bevy_sprite::mesh2d_view_bindings"] = bevy_root ..
        --         "crates/bevy_sprite_render/src/mesh2d/mesh2d_view_bindings.wgsl",
        --         ["bevy_sprite::mesh2d_view_types"] = bevy_root ..
        --         "crates/bevy_sprite_render/src/mesh2d/mesh2d_view_types.wgsl",
        --         ["bevy_sprite::sprite_view_bindings"] = bevy_root ..
        --         "crates/bevy_sprite_render/src/render/sprite_view_bindings.wgsl",
        --         ["bevy_ui::ui_node"] = bevy_root .. "crates/bevy_ui_render/src/ui.wgsl",
        --         ["bevy_ui::ui_vertex_output"] = bevy_root .. "crates/bevy_ui_render/src/ui_vertex_output.wgsl",

        --     }
        -- }
    }
})
