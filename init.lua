-- Options
local opt = vim.opt

vim.g.scala_recommended_style = 0

opt.number = true             -- 显示行号
opt.relativenumber = true     -- 相对行号
opt.mouse = 'a'               -- 启用鼠标
opt.clipboard = 'unnamedplus' -- 剪贴板与系统互联
opt.termguicolors = true      -- 启用真彩色
opt.expandtab = true          -- tab转空格
opt.shiftwidth = 4            -- 缩进宽度
opt.tabstop = 4               -- 缩进宽度
opt.softtabstop = 4
opt.undofile = true           -- 持久化撤销历史
opt.scrolloff = 8             -- 滚动保留上下文
opt.backup = false            -- 禁用备份文件

vim.o.timeout = true
vim.o.timeoutlen = 300

-- Keymaps
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

local keymap = vim.keymap.set

-- Ctrl + Backspace
keymap('i', '<C-BS>', '<C-w>', { desc = '删除前一个单词' })
-- Ctrl + 左右方向键按单词移动
keymap({ 'n', 'x', 'o' }, '<C-h>', 'b', { desc = '向左移动一个单词' })
keymap({ 'n', 'x', 'o' }, '<C-l>', 'w', { desc = '向右移动一个单词' })
keymap('i', '<C-Left>', '<C-o>b', { desc = '向左移动一个单词' })
keymap('i', '<C-Right>', '<C-o>w', { desc = '向右移动一个单词' })
-- 清除高亮
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = '清除搜索高亮' })
-- Copy
keymap('', '<leader>y', '"+y', { desc = "复制" })
keymap('n', '<leader>p', '"+p', { desc = "粘贴" })
-- 行首行尾跳转
keymap('n', 'H', '^', { desc = '跳转到行首' })
keymap('n', 'L', '$', { desc = '跳转到行尾' })
-- 上下5行快速移动
keymap('n', 'J', '5j', { desc = '向下5行' })
keymap('n', 'K', '5k', { desc = '向上5行' })
-- 可视模式下缩进，并在缩进后保持选区
keymap('x', '<Tab>', '>gv', { desc = '增加选中代码的缩进' })
keymap('x', '<S-Tab>', '<gv', { desc = '减少选中代码的缩进' })

-- 保存
keymap('n', '<leader>w', '<cmd>write<CR>', { desc = '保存文件' })
keymap('n', '<leader>q', '<cmd>quit<CR>', { desc = '退出当前窗口' })

-- 折叠
keymap('n', '<leader>z', 'za', { desc = '切换当前折叠' })
keymap('n', '<leader>Z', 'zA', { desc = '递归切换折叠' })

vim.keymap.set('n', '<leader>v', function()
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
    if #diagnostics > 0 then
        -- 取第一个诊断（通常也是 inline 显示的那个）
        local msg = diagnostics[1].message
        vim.fn.setreg('+', msg)
        vim.notify('Copied: ' .. msg)
    end
end, { buffer = true, desc = '复制当前行诊断' })
-- Plugin
vim.pack.add({
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/windwp/nvim-autopairs' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/sphamba/smear-cursor.nvim' },
    { src = 'https://github.com/ibhagwan/fzf-lua' },
    { src = 'https://github.com/xiyaowong/transparent.nvim' },
    { src = 'https://github.com/rebelot/kanagawa.nvim' },
    { src = 'https://github.com/neanias/everforest-nvim' },
    { src = 'https://github.com/tpope/vim-repeat' },
    { src = 'https://codeberg.org/andyg/leap.nvim' },
    { src = 'https://github.com/Saghen/blink.cmp' },
    { src = 'https://github.com/saghen/blink.lib' },
    { src = 'https://github.com/L3MON4D3/LuaSnip' },
    { src = 'https://github.com/folke/which-key.nvim' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
    { src = 'https://github.com/MunifTanjim/nui.nvim' },
    { src = 'https://github.com/rcarriga/nvim-notify' },
    { src = 'https://github.com/folke/noice.nvim' },
    { src = 'https://github.com/akinsho/toggleterm.nvim' },
    { src = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim' },
    { src = 'https://github.com/stevearc/conform.nvim' },
    { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
    { src = "https://github.com/OXY2DEV/markview.nvim" },
    { src = "https://github.com/scalameta/nvim-metals" },
})

-- theme kanagawa
-- vim.cmd("colorscheme kanagawa-wave")
-- theme everforest
require('everforest').setup({
    transparent_background_level = 1,
})
vim.cmd("colorscheme everforest")

-- Plugin Config
-- Lualine config
require('lualine').setup({})

-- tiny inline diagnostic
require("tiny-inline-diagnostic").setup({
    preset = "classic",
    transparent_bg = true,
    transparent_currsorline = true,
})
vim.diagnostic.config({ virtual_text = false })

-- conform config
require('conform').setup({
    formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        json = { 'jq' },

        -- 🦀 Rust
        rust = { "rustfmt" },

        -- 🟦 C++
        c = { "clang-format" },
        cpp = { "clang-format" },

        -- 🐹 Go
        go = { "gofmt", "goimports", stop_after_first = true },

        -- 🟣 Haskell
        haskell = { "hls" },

        -- 🌐 Web (Vue / JS / TS)
        vue = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },

        -- 🎨 CSS / SCSS / HTML
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
    formatters = {
        ["clang-format"] = {
            prepend_args = {
                "--style={IndentWidth: 4, TabWidth: 4, UseTab: Never }",
            }
        }
    }
})

-- nvim-tree config
require('nvim-tree').setup({
    view = {
        width = 35,
    },
    filters = {
        dotfiles = false,
        git_ignored = false,
        custom = {
            "^ndoe_modules$",
            ".git",
            ".codex",
            ".agent",
            ".bsp",
            ".metals",
            ".github",
            "out",
            "obj_dir",
        }
    }
})
keymap('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = '切换文件树' })

-- fzf lua config
require('fzf-lua').setup({
    winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = 'rounded',
        backdrop = 60,
    },

    previewers = {
        builtiin = {
            syntax = true,
            syntax_limit_b = 1024 * 1024,
        },
    },

    file_icons = true,
    color_icons = true,
    git_icons = true
})

require('fzf-lua').register_ui_select()

-- 文件 (<leader>ff = file find)
keymap('n', '<leader>ff', '<cmd>FzfLua files<CR>', { desc = '查找文件' })
keymap('n', '<leader>fg', '<cmd>FzfLua live_grep<CR>', { desc = '搜索文件内容' })
keymap('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = '搜索缓冲区' })
keymap('n', '<leader>fh', '<cmd>FzfLua oldfiles<CR>', { desc = '搜索最近文件' })

-- Git (<leader>fg = git)
keymap('n', '<leader>gf', '<cmd>FzfLua git_files<CR>', { desc = '查找 Git 文件' })
keymap('n', '<leader>gs', '<cmd>FzfLua git_status<CR>', { desc = '查看 Git 状态' })
keymap('n', '<leader>gc', '<cmd>FzfLua git_commits<CR>', { desc = '查看 Git 提交' })
keymap('n', '<leader>gh', '<cmd>FzfLua git_hunks<CR>', { desc = '查看 Git 改动块' })

-- LSP (<leader>fl = lsp)
keymap('n', 'gd', '<cmd>FzfLua lsp_definitions<CR>', { desc = '跳转到定义' })
keymap('n', 'gr', '<cmd>FzfLua lsp_references<CR>', { desc = '查找引用' })
keymap('n', 'gi', '<cmd>FzfLua lsp_implementations<CR>', { desc = '跳转到实现' })
keymap('n', 'ga', '<cmd>FzfLua lsp_code_actions<CR>', { desc = '代码操作' })
keymap('n', 'gf', '<cmd>FzfLua lsp_finder<CR>', { desc = 'LSP 导航' })

local code_symbol_kinds = {
    Class = true,
    Function = true,
    Method = true,
    Constructor = true,
    Interface = true,
    Struct = true,
}
local function code_symbols_only(item)
    return code_symbol_kinds[item.kind] == true
end
keymap('n', '<leader>fs', function()
    require('fzf-lua').lsp_document_symbols({
        regex_filter = code_symbols_only,
    })
end, { desc = '搜素当前文件函数/类' })
keymap('n', '<leader>fS', function()
    require('fzf-lua').lsp_live_workspace_symbols({
        regex_filter = code_symbols_only,
    })
end, { desc = '搜素当前文件函数/类' })

-- 诊断
keymap('n', '<leader>dd', '<cmd>FzfLua diagnostics_document<CR>', { desc = '当前文件诊断' })
keymap('n', '<leader>dw', '<cmd>FzfLua diagnostics_workspace<CR>', { desc = '工作区诊断' })

-- Resume
keymap('n', '<leader>fr', '<cmd>FzfLua resume<CR>', { desc = '恢复上次搜索' })

-- Noice config
require("noice").setup({
    cmdline = {
        view = "cmdline_popup",
        format = {
            cmdline = { view = "cmdline_popup" },
            search_down = { view = "cmdline_popup" }, -- /
            search_up = { view = "cmdline_popup" },   -- ?
        },
    },
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
    },
    presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
    },
})

-- toggleterm config
keymap('t', '<Esc>', [[<C-\><C-n>]], { desc = '退出终端模式' })
require('toggleterm').setup({
    direction = 'float',
    float_opts = {
        border = "rounded",
    }
})

keymap('n', '<leader>t', '<cmd>ToggleTerm<CR>', { desc = '切换浮动终端' })

local java_runner = require('java_runner')
keymap('n', '<leader>jc', java_runner.run_main, { desc = '运行当前 Java main' })
keymap('n', '<leader>jt', java_runner.run_test_class, { desc = '运行当前 Java 测试类' })
keymap('n', '<leader>jf', java_runner.run_test_method, { desc = '运行光标处 Java 测试' })

-- Treesitter config
local setup_treesitter = function()
    local treesitter = require("nvim-treesitter")
    treesitter.setup({})
    local ensure_installed = {
        "vim",
        "vimdoc",
        "rust",
        "c",
        "cpp",
        "go",
        "html",
        "css",
        "javascript",
        "java",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "latex",
        "python",
        "typescript",
        "vue",
        "svelte",
        "bash",
        'haskell',
        "yaml",
        "scss",
        "scala",
    }

    local config = require("nvim-treesitter.config")

    local already_installed = config.get_installed()
    local parsers_to_install = {}

    for _, parser in ipairs(ensure_installed) do
        if not vim.tbl_contains(already_installed, parser) then
            table.insert(parsers_to_install, parser)
        end
    end

    if #parsers_to_install > 0 then
        treesitter.install(parsers_to_install)
    end

    local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
            if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
                vim.treesitter.start(args.buf)
            end
        end,
    })
end

setup_treesitter()

-- autopairs config
require('nvim-autopairs').setup()

-- smaer cursor config
require('smear_cursor').setup({
})

-- Transparent config
require("transparent").setup({
    groups = {
        'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
        'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
        'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
        'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
        'EndOfBuffer',
    },
    extra_groups = {
        -- blink transparent
        'BlinkCmpMenu',
        'BlinkCmpMenuBorder',
        'BlinkCmpDoc',
        'BlinkCmpDocBorder',

        -- lualine transparent
        'lualine_c_normal',
        'lualine_c_insert',
        'lualine_c_visual',
        'lualine_c_replace',
        'lualine_c_command',

        -- which-key
        "WhichKey",
        "WhichKeyGroup",
        "WhichKeyDesc",
        "WhichKeySeperator",
        "WhichKeyFloat",
        "WhichKeyBorder",
        "WhichKeyValue",

    },
    exclude_groups = {},
    on_clear = function() end,
})
require('transparent').clear_prefix('noice')
require('transparent').clear_prefix('which-key')
require('transparent').clear_prefix('Markview')

-- Leap nvim config
keymap({ 'n', 'x', 'o' }, 's', '<Plug>(leap)', { desc = 'Leap 跳转' })
keymap('n', 'S', '<Plug>(leap-from-window)', { desc = '跨窗口 Leap 跳转' })

-- which-key config
local wk = require('which-key')

wk.setup({
    preset = "modern"
})

wk.add({
    { '<leader>f', group = '搜索' },
    { '<leader>g', group = 'Git' },
    { '<leader>d', group = '诊断' },
    { '<leader>j', group = 'Java' },
    { '<leader>jd', group = 'Java 调试' },
})

keymap('n', '<leader>?', function()
    wk.show({ global = false })
end, { desc = '查看当前缓冲区快捷键' })

-- Blink.cmp config
require("blink.cmp").setup({
    keymap = {
        preset = "none",
        ["<C-i>"] = { "show", "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
    },
    appearance = { nerd_font_variant = "mono" },
    completion = { menu = { auto_show = true } },
    sources = { default = { "lsp", "path", "buffer", "snippets" } },
    snippets = {
        expand = function(snippet)
            require("luasnip").lsp_expand(snippet)
        end,
    },

    fuzzy = {
        implementation = "prefer_rust_with_warning",
        prebuilt_binaries = { download = true },
    },
})
keymap('n', '<leader>k', vim.lsp.buf.hover, { desc = '显示函数文档' })
keymap('i', '<C-k>', vim.lsp.buf.hover, { desc = '显示函数文档' })

-- metals / scala lsp
local metals_config = require("metals").bare_config()
-- 补全
metals_config.capabilities = require("blink.cmp").get_lsp_capabilities()
-- metals 设置
metals_config.init_options.statusBarProvide = "off"

local scala_cli = vim.fn.exepath("scala-cli")
if scala_cli ~= "" then
    metals_config.settings = {
        scalaCliLauncher = scala_cli,
    }
end

-- 启动 Metals
local metals_group =
    vim.api.nvim_create_augroup("nvim-metals", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = metals_group,
    pattern = { "scala", "sbt" },
    callback = function()
        require("metals").initialize_or_attach(metals_config)
    end,
})

-- markdown
require("markview").setup({
    preview = {
        enable = true,
        enable_hybrid_mode = true,
    },
    latex = {
        enable = true,
        inlines = {
            padding_left = "",
            padding_right = "",
        },
    },
})

-- Mason
require('mason').setup()
require('mason-lspconfig').setup()
require('mason-tool-installer').setup({
    ensure_installed = {
        "lua_ls",
        "hls",
        "rust_analyzer",
        "gopls",
        "vue_ls",
        "vtsls",
        "eslint_d",
        "pyright",
        "cssls",
        "clangd",
        "clang-format",
        "jdtls"
    }
})

vim.lsp.config["*"] = {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
}

require("lsp.vtsls")

-- CS61B Spring 2021 把依赖 jar 放在课程仓库中，而不是标准的 src 目录。
local cs61b_root = vim.fn.expand('~/workSpace/CS61B')
vim.lsp.config('jdtls', {
    -- CS61B 的各个 lab 是同一 Git 仓库中的独立 Maven 项目。
    -- 对它优先使用最近的 pom.xml，避免 jdtls 把整个仓库当成一个工作区。
    root_dir = function(bufnr, on_dir)
        local file = vim.api.nvim_buf_get_name(bufnr)
        local normalized_file = vim.fs.normalize(file)
        local normalized_cs61b_root = vim.fs.normalize(cs61b_root)

        if normalized_file:sub(1, #normalized_cs61b_root + 1) == normalized_cs61b_root .. '/' then
            on_dir(vim.fs.root(normalized_file, {
                'pom.xml',
                'build.gradle',
                'build.gradle.kts',
                'build.xml',
            }) or normalized_cs61b_root)
            return
        end

        on_dir(vim.fs.root(normalized_file, {
            { 'mvnw',      'gradlew', 'settings.gradle', 'settings.gradle.kts', '.git' },
            { 'build.xml', 'pom.xml', 'build.gradle',    'build.gradle.kts' },
        }))
    end,
    settings = {
        java = {
            project = {
                referencedLibraries = {
                    cs61b_root .. '/library-sp21/javalib/*.jar',
                    cs61b_root .. '/proj0/javalib/*.jar',
                },
            },
        },
    },
})

vim.lsp.enable({
    "lua_ls",
    "hls",
    "rust_analyzer",
    "gopls",
    "vtsls",
    "vue_ls",
    "pyright",
    "cssls",
    "clangd",
    "jdtls"
})
