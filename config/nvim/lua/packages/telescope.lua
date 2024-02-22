local M = {}

M.name = "telescope"

M.config = {
    pickers = {
        colorscheme = {
            enable_preview = true,
        },
    },
    extensions = {
        file_browser = {
            theme = "dropdown",
            previewer = false,
            layout_config = {
                center = {
                    height = 0.8,
                    width = 0.4,
                }
            }
        },
    },
}

M.post_setup = function()
    require("telescope").load_extension "file_browser"

    vim.keymap.set('n', '<leader>f', ':Telescope find_files<CR>', { silent = true })
    vim.keymap.set('n', '<leader>b', ':Telescope buffers<CR>', { silent = true })
    vim.keymap.set('n', '<leader>g', ':Telescope live_grep<CR>', { silent = true })
    vim.keymap.set('v', '<leader>g', 'y<ESC>:Telescope live_grep default_text=<c-r>0<CR>', { silent = true })
    vim.keymap.set("n", "<leader>y", ":Telescope file_browser<CR>", { silent = true })
end

return M
