return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
           'nvim-lua/plenary.nvim',
           {
               'nvim-telescope/telescope-fzf-native.nvim',
               run = 'make',
               cond = vim.fn.executable('make') == 1,
           }
        },
        config = function()

            -- Keymaps
            local map = require('helpers').map
            local telescope = require('telescope.builtin')

            map('n', '<leader>f', telescope.find_files, "Find Files")
            map('n', '<leader>b', telescope.buffers,    "Open Buffers")
            map('n', '<leader>g', telescope.live_grep,  "Grep")
            -- vim.keymap.set('v', '<leader>g', 'y<ESC>:Telescope live_grep default_text=<c-r>0<CR>', { silent = true })
            -- vim.keymap.set("n", "<leader>y", ":Telescope file_browser<CR>", { silent = true })
        end
    }
}
