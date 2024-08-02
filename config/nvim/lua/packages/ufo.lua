local M = {}

M.config = {
    close_fold_kinds_for_ft = {'comment'},
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
}

M.post_setup = function()
    vim.o.foldcolumn     = '1'
    vim.o.foldlevel      = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable     = true

    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)
end

return M
