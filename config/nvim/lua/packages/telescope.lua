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
end

return M
