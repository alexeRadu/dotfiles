local M = {}

M.disable    = true
M.name       = 'dapui'
M.config     = {}
M.post_setup = function()
    vim.api.nvim_create_user_command('DapuiOpen', function()
        require('dapui').open()
    end, {nargs = 0})

    vim.api.nvim_create_user_command('DapuiClose', function()
        require('dapui').close()
    end, {nargs = 0})

    vim.keymap.set('n', '<leader>m', function()
        require('dapui').eval('a = 0')
    end)
end

return M
