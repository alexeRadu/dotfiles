local M = {}

M.config = {
    position = "left"
}

M.post_setup = function ()
    vim.keymap.set('n', '<leader>o', function()
        require('symbols-outline').toggle_outline()
    end)
end

return M
