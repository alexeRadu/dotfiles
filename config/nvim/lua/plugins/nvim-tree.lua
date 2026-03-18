return {
    {
        'nvim-tree/nvim-tree.lua',
        version = '*',
        lazy = false,
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            local config_window = function()
                local scr_w = vim.opt.columns:get()
                local scr_h = vim.opt.lines:get()
                local tree_w = 100
                local tree_h = math.floor(scr_h * 0.8)

                return {
                    border = 'single',
                    relative = 'editor',
                    width = tree_w,
                    height = tree_h,
                    col = (scr_w - tree_w) / 2,
                    row = (scr_h - tree_h) / 2,
                }
            end

            local config = {
                hijack_cursor = true,
                renderer = {
                    indent_width = 3,
                    indent_markers = {
                        enable = true,
                    },
                    icons = {
                        show = {
                            modified = true,
                        },
                        git_placement = "after",
                    }
                },
                view = {
                    cursorline = true,
                    float = {
                        enable = false,
                        open_win_config = config_window,
                    },
                },
            }

            require('nvim-tree').setup(config)

            -- Keymaps
            local map = require('helpers').map
            local api = require('nvim-tree.api')

            local toggle_nv_tree = function()
                api.tree.toggle({
                    path = '<args>',
                    find_file = true,
                    focus = true,
                })
            end

            local toggle_floating = function()
                if config.view.float.enable == false then
                    config.view.float.enable = true
                else
                    config.view.float.enable = false
                end

                require('nvim-tree').setup(config)
                api.tree.open()
            end

            map('n', '<leader>n', toggle_nv_tree, 'Toggle Nvim-Tree')
            map('n', '<leader>t', toggle_floating, 'Toggle Nvim-Tree Floating')
        end
    }
}
