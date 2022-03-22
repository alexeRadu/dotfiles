local fn  = vim.fn
local api = vim.api


--api.nvim_set_option("guifont", "IBM Plex Mono Light:h10")
api.nvim_set_keymap("n", "<F5>", ":luafile %<CR>", {})

require("plugins")
