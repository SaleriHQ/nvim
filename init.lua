-- Options
local opt = vim.opt

opt.number = true             -- 显示行号
opt.relativenumber = true     -- 相对行号
opt.mouse = 'a'               -- 启用鼠标
opt.clipboard = 'unnamedplus' -- 剪贴板与系统互联
opt.termguicolors = true      -- 启用真彩色
opt.expandtab = true          -- tab转空格
opt.shiftwidth = 4            -- 缩进宽度
opt.tabstop = 4               -- 缩进宽度
opt.undofile = true           -- 持久化撤销历史
opt.scrolloff = 8             -- 滚动保留上下文
opt.backup = false            -- 禁用备份文件

vim.o.timeout = true
vim.o.timeoutlen = 300

-- Keymaps
local keymap = vim.keymap.set
-- Ctrl + Backspace
keymap('i', '<C-BS>', '<C-w>')
-- 清除高亮
keymap("n", "<Esc>", ":noh<CR>")
-- Copy
keymap('', '<leader>y', '"+y', { desc = "复制" })
keymap('n', '<leader>p', '"+p', { desc = "粘贴" })
-- 行首行尾跳转
keymap('n', 'H', '^', { desc = '跳转到行首' })
keymap('n', 'L', '$', { desc = '跳转到行尾' })
-- 上下5行快速移动
keymap('n', 'J', '5j', { desc = '向下5行' })
keymap('n', 'K', '5k', { desc = '向上5行' })

-- 空格为leader，反斜杠为局部leader
vim.g.mapleader = ' '
local keymap = vim.keymap.set
local opts = { silent = true, noremap = true }
-- 保存
keymap('n', '<leader>w', ':write<CR>', { desc = '保存文件' })
keymap('n', '<leader>q', ':quit<CR>', { desc = '退出当前窗口' })

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
end, { buffer = true })
-- Plugin
vim.pack.add({
    { src = 'https://github.com/RRethy/base16-nvim' },
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/windwp/nvim-autopairs' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/sphamba/smear-cursor.nvim' },
    { src = 'https://github.com/ibhagwan/fzf-lua' },
    { src = 'https://github.com/xiyaowong/transparent.nvim' },
    { src = 'https://github.com/rebelot/kanagawa.nvim' },
    { src = 'https://github.com/tpope/vim-repeat' },
    { src = 'https://codeberg.org/andyg/leap.nvim' },
    { src = 'https://github.com/Saghen/blink.cmp' },
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
})

-- theme set
vim.cmd("colorscheme kanagawa-wave")
-- require('matugen').setup()

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
        c = { "clang_format" },
        cpp = { "clang_format" },

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
    }
})

-- nvim-tree config
require('nvim-tree').setup({
    view = {
        width = 35,
    },
    filters = {
        dotfiles = false,
    }
})
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = '切换文件树' })

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
keymap('n', '<leader>ff', ':FzfLua files<CR>', opts)
keymap('n', '<leader>fg', ':FzfLua live_grep<CR>', opts)
keymap('n', '<leader>fb', ':FzfLua buffers<CR>', opts)
keymap('n', '<leader>fh', ':FzfLua oldfiles<CR>', opts)

-- Git (<leader>fg = git)
keymap('n', '<leader>gf', ':FzfLua git_files<CR>', opts)
keymap('n', '<leader>gs', ':FzfLua git_status<CR>', opts)
keymap('n', '<leader>gc', ':FzfLua git_commits<CR>', opts)
keymap('n', '<leader>gh', ':FzfLua git_hunks<CR>', opts)

-- LSP (<leader>fl = lsp)
keymap('n', 'gd', ':FzfLua lsp_definitions<CR>', opts)
keymap('n', 'gr', ':FzfLua lsp_references<CR>', opts)
keymap('n', 'gi', ':FzfLua lsp_implementations<CR>', opts)
keymap('n', 'ga', ':FzfLua lsp_code_actions<CR>', opts)
keymap('n', 'gf', ':FzfLua lsp_finder<CR>', opts)

-- 诊断
keymap('n', '<leader>dd', ':FzfLua diagnostics_document<CR>', opts)
keymap('n', '<leader>dw', ':FzfLua diagnostics_workspace<CR>', opts)

-- Resume
keymap('n', '<leader>fr', ':FzfLua resume<CR>', opts)

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
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
require('toggleterm').setup({
    direction = 'float',
    float_opts = {
        border = "rounded",
    }
})

vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>")

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
        "json",
        "lua",
        "markdown",
        "python",
        "typescript",
        "vue",
        "svelte",
        "bash",
        'haskell',
        "yaml",
        "scss",
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
require('smear_cursor').setup()

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

-- Leap nvim config
keymap({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
keymap('n', 'S', '<Plug>(leap-from-window)')

-- which-key config
local wk = require('which-key')

wk.setup({
    preset = "modern"
})

wk.add({
    -- 窗口
    { "<leader>sv", desc = "垂直分割" },
    { "<leader>sh", desc = "水平分割" },
    { "<leader>=", desc = "等分所有窗口" },
    { "<leader>sc", desc = "关闭当前窗口" },
    -- 文件搜索
    { "<leader>ff", desc = "查找文件" },
    { "<leader>fg", desc = "查找文件内容" },
    { "<leader>fb", desc = "搜索缓冲区" },
    { "<leader>fh", desc = "搜索旧文件" },
    { "<leader>fr", desc = "恢复上次搜索" },
    -- Git
    { "<leader>gf", desc = "查找git内的文件" },
    { "<leader>gs", desc = "查找git status" },
    { "<leader>gc", desc = "查找git commits" },
    { "<leader>gh", desc = "查找git hunks" },
    -- LSP
    { "gd", desc = "跳转到定义" },
    { "gr", desc = "查找引用" },
    { "gi", desc = "跳转到实现" },
    { "ga", desc = "代码动作" },
    { "gf", desc = "LSP浏览器" },
    -- 诊断
    { "<leader>dd", desc = "当前文件诊断" },
    { "<leader>dw", desc = "工作区诊断" },
})

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
        implementation = "lua",
        prebuilt_binaries = { download = true },
    },
})
keymap('n', '<leader>k', vim.lsp.buf.hover, { desc = '显示函数文档' })
keymap('i', '<C-k>', vim.lsp.buf.hover, { desc = '显示函数文档' })

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
    }
})

vim.lsp.config["*"] = {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
}

require("lsp.vtsls")

vim.lsp.enable({
    "lua_ls",
    "hls",
    "rust_analyzer",
    "gopls",
    "vtsls",
    "vue_ls",
    "pyright",
    "cssls",
})
