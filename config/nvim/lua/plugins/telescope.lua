return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
           'nvim-lua/plenary.nvim',
           { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function()

            -- Keymaps
            local map = require('helpers').map
            local telescope = require('telescope.builtin')
            local get_visual = require('helpers').get_visual

            local live_grep_selected = function()
                local selection = get_visual()

                telescope.live_grep({ default_text = string.format([[%s]], selection) })
            end

            map('n', '<leader>f', telescope.find_files, "Find Files")
            map('n', '<leader>b', telescope.buffers,    "Open Buffers")
            map('n', '<leader>g', telescope.live_grep,  "Grep")
            map('v', '<leader>g', live_grep_selected,   "Live Grep")
        end
    }
}
