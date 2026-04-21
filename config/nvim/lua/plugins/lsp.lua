return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            { 'folke/lazydev.nvim', ft = "lua", opts = {} },
        },
        config = function()
            -- We install a list of LSP servers via mason
            -- Mason can install external packages like LSP servers, DAP servers, Linters, Formatters
            -- For more info about what you can install execute ':Mason'
            servers = {
                clangd = true,
            }

            require('mason').setup()
            require('mason-lspconfig').setup({
                ensure_installed = {
                    "clangd",           -- LSP for C, C++
                    "lua_ls",           -- LSP for Lua
                    "pyright",          -- LSP for Python
                }
            })

            vim.lsp.enable('clangd')

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local map       = require('helpers').map
                    local telescope = require('telescope.builtin')

                    map('n', 'gd', vim.lsp.buf.definition)
                    map('n', 'gr', telescope.lsp_references)
                end,
            })
        end
    }
}
