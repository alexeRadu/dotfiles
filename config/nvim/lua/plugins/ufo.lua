return {
    {
        'kevinhwang91/nvim-ufo',
        dependencies = { 'kevinhwang91/promise-async' },
        config = function()
            -- Note:
            -- foldcolumn = '0' removes any marks that show the folding level or folding signs
            -- foldcolumn = '1' has currently the flaw that shows both the folding signs and the folding level
            --
            -- this ssue will be fixed in a next release with 'foldinner' option that will be automatically
            -- set to none; for the moment deal with the pain
            vim.o.foldcolumn     = '1'
            vim.o.foldlevel      = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable     = true
            vim.o.fillchars      = table.concat({
                "eob: ",
                "fold: ",
                "foldopen:-",
                "foldclose:+",
                "foldsep: ",
            }, ',')

            local ufo = require('ufo')

            ufo.setup({
                close_fold_kinds_for_ft = {
                    default = {'comment', 'function_definition'},
                },
                provider_selector = function(bufnr, filetype, buftype)
                    return {'treesitter', 'indent'}
                end
            })

            -- Keybindings
            vim.keymap.set('n', 'zR', ufo.openAllFolds)
            vim.keymap.set('n', 'zM', ufo.closeAllFolds)
            vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds)
            vim.keymap.set('n', 'zm', function() ufo.closeFoldsWith(1) end)
        end
    },
}
