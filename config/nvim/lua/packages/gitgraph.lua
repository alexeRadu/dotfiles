local M = {}

M.name = "gitgraph"

M.config = {
}

M.post_setup = function()
    vim.keymap.set('n', '<leader>l', ':lua require("gitgraph").draw({}, {all = "--all", depth=10})')
end

return M
