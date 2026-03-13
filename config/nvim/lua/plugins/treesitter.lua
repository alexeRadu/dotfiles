return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter').setup {
                ensure_installed = {
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
                },

                sync_install = false,

                highlight = {
                    enable = true,
                },

                indent = {
                    enable = true,
                },

                playground = {
                    enable = true
                },

                query_linter = {
                    enable = true,
                    use_virtual_text = true,
                    lint_events = {"BufWrite", "CursorHold"},
                },
            }
        end
    }
}
