- [ ] Lsp Config
- [x] Ctrl+Backspce删除单词
- [x] 跳转回跳转前的位置
- [x] 快速跳转到某个单词
- [ ] code action的配置
- [x] status line的配置
- [x] 浮动终端
    <leader> t
- [x] 搜索器的配置
- [x] 行内显示warning, error
- [x] 跳转上一个下一个搜索
    n / N
- [ ] 移动一整行
- [x] 隐藏lualine下面的命令
- [x] 代码格式化
- [x] lualine美化
- [x] 配置neovim联动noctalia
- [ ] 高亮显示Todo和查找Todo
- [ ] 一键注释



vim.lsp.config['lua_ls'] = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            }
        }
    },
}

vim.lsp.config['hls'] = {
    cmd = { 'haskell-language-server-wrapper', '--lsp' },
    filetypes = {
        'haskell',
    },
    root_markers = {
        'hie.yaml',
        'stack.yaml',
        'cabal.project',
        '*.cabal',
        'package.yaml',
    },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config['rust_analyzer'] = {
    cmd = { 'rust-analyzer' },
    filetypes = {
        'rust'
    },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config['gopls'] = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod' },
}

vim.lsp.config["vtsls"] = require("lsp.vtsls")
vim.lsp.config["vue_ls"] = require("lsp.vue_ls")

vim.lsp.enable({
    'lua_ls',
    'hls',
    'gopls',
    "rust_analyzer",
    "vtsls",
    "vue_ls",
})

