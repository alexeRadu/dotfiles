local M = {}

M.name = "nvim-semantic-tokens"

M.config = {
    preset = "default",
    highlighters = { require 'nvim-semantic-tokens.table-highlighter' },
}

return M
