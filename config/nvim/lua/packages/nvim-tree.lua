local M = {}

M.config =  {
    disable_netrw = true,
    view = {
        adaptive_size = true,
    },
}

M.post_setup = function()
    vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', { silent = true })
end

return M
