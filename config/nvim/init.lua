local fn  = vim.fn
local api = vim.api


--api.nvim_set_option("guifont", "IBM Plex Mono Light:h10")
api.nvim_set_keymap("n", "<f5>", ":luafile %<cr>", {})

vim.g.mapleader = " "

-- settings
vim.o.number = true
vim.o.rnu = true
vim.o.cursorline = true
vim.o.mouse = 'a'

require("plugins")

-- telescope.nvim settings
require("telescope").setup {
	extensions = {
		file_browser = {
			--theme = "ivy",
		}
	},
}

require("telescope").load_extension "file_browser"

api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<cr>", {})
api.nvim_set_keymap("n", "<leader>fb", ":Telescope buffers<cr>", {})


-- telescope-file-browser.nvim settings
api.nvim_set_keymap("n", "<leader>fe", ":Telescope file_browser<cr>", { noremap = true })

-- VSCode.nvim settings
vim.g.vscode_style = "dark"
vim.cmd [[colorscheme vscode ]]

-- gitsigns.nvim
require('gitsigns').setup()
