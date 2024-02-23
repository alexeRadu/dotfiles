local M = {}

local on_attach = function(client, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, {
            noremap = true,
            buffer = bufnr,
            silent = true,
            desc = desc,
        })
    end

    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('gd', vim.lsp.buf.definition, 'Goto Definition')
    nmap('K', vim.lsp.buf.hover)
    nmap('gi', vim.lsp.buf.implementation)

    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end)

    nmap('<leader>dn', vim.diagnostic.goto_next)
    nmap('<leader>dp', vim.diagnostic.goto_prev)
    nmap('<leader>dl', "<cmd>Telescope diagnostics<cr>")

    nmap('<leader>rn', vim.lsp.buf.rename)
    nmap('<leader>ca', vim.lsp.buf.code_action)

    -- TODO: this should be removed for neovim 0.9 since 'semanticTokens' functionatlity
    -- will be included in the default neovim
    local caps = client.server_capabilities
    if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
        local augroup = vim.api.nvim_create_augroup("SemanticTokens", {})
        vim.api.nvim_create_autocmd("TextChanged", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.semantic_tokens_full()
            end,
        })

        vim.lsp.buf.semantic_tokens_full()
    end
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local configs = require('lsp-configs')

M.post_setup = function()
    vim.api.nvim_set_hl(0, "LspComment", { link = "Comment" })

    for config_name, config in pairs(configs) do
        local setup_settings = {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = config.settings,
        }

        if config.cmd then
            setup_settings.cmd = config.cmd
        end

        require('lspconfig')[config_name].setup(setup_settings)
    end
end

return M
