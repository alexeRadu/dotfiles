local M = {}

M.config = {
    close_fold_kinds_for_ft = {
        default = {},
        lua = {'function_definition'},
        cpp = {'comment', 'function_definition'},
        c = {'comment', 'function_definition'}
    },
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
}

M.post_setup = function()
    vim.o.foldcolumn     = '1'
    vim.o.foldlevel      = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable     = true
    vim.o.fillchars      = [[eob: ,fold: ,foldopen:-,foldsep: ,foldclose:+]]

    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zm', require('ufo').closeAllFolds)
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)
end

return M
