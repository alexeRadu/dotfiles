local M = {}

M.config = {
    close_fold_kinds = {'comment'},
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
}

return M
