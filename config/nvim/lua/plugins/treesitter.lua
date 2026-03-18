return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        branch = 'main',
        config = function()
            require('nvim-treesitter').install {
                'c',
                'cpp',
                'lua',
                'vim',
                'python',
                'bash',
                'cmake',
                'make',
                'ninja',
                'diff',
                'gitattributes',
                'gitcommit',
                'json',
                'markdown',
                'java',
                'javascript',
                'typescript',
                'html',
                'css',
                'go',
            }

            local group = vim.api.nvim_create_augroup("custom-treesitter", {clear = true})
            vim.api.nvim_create_autocmd("FileType", {
                group = group,
                pattern = '*',
                callback = function(args)
                    local bufnr = args.buf
                    local ft    = vim.bo[bufnr].filetype
                    local lang  = vim.treesitter.language.get_lang(ft)

                    if lang == nil then
                        return
                    end

                    if not vim.treesitter.language.add(lang) then
                        local available = vim.g.ts_available or require('nvim-treesitter').get_available()
                        if not vim.g.ts_available then
                            vim.g.ts_available = available
                        end

                        if vim.tbl_contains(available, lang) then
                            vim.print(string.format("Installing parsers nad queries for %s", lang))
                            require('nvim-treesitter').install(lang)
                        end
                    end

                    if vim.treesitter.language.add(lang) then
                        -- start treesitter highlighting
                        vim.treesitter.start(args.buf, lang)
                    end
                end,
            })
        end
    }
}
