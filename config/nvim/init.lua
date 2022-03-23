local fn  = vim.fn
local api = vim.api


--api.nvim_set_option("guifont", "IBM Plex Mono Light:h10")
api.nvim_set_keymap("n", "<F5>", ":luafile %<CR>", {})

vim.g.mapleader = " "

require("plugins")

api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<cr>", {})
api.nvim_set_keymap("n", "<leader>fb", ":Telescope buffers<cr>", {})
