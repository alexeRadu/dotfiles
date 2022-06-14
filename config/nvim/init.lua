local fn  = vim.fn
local api = vim.api
local g   = vim.g
local o   = vim.o

function bind_key(mode, key, result)
	vim.api.nvim_set_keymap(mode, key, result, {noremap = true, silent = true})
end

g.mapleader  = ' '

o.background     = 'dark'
o.errorbells     = false
o.number         = true
o.relativenumber = true
o.termguicolors  = true
o.list           = true
vim.opt.listchars:append('space: ')
vim.opt.listchars:append("eol:↴")

vim.cmd [[packadd packer.nvim]]

require('packer').startup(function()
	use {
		'nvim-telescope/telescope.nvim',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

	use {
		'kyazdani42/nvim-tree.lua',
		requires = {
			'kyazdani42/nvim-web-devicons',
		},
	}

	use {'nvim-treesitter/nvim-treesitter'}
	use {'neovim/nvim-lspconfig'}
	use {'williamboman/nvim-lsp-installer'}
	use {'simrat39/symbols-outline.nvim'}
  use {'lukas-reineke/indent-blankline.nvim'}
  use {'lukas-reineke/onedark.nvim'}
  use {'numToStr/Comment.nvim'}
end)


require('nvim-tree').setup { }
require('nvim-treesitter.configs').setup {
	ensure_installed = {"c", "lua", "python"},
	highlight = {enable = true}
}
require('indent_blankline').setup {
  show_current_context = true,
  show_current_context_start = true,
  show_end_of_line     = true,
}
require('onedark').setup()
require('Comment').setup()

bind_key('n', '<leader>ff', ':Telescope find_files<CR>')
bind_key('n', '<leader>fb', ':Telescope buffers<CR>')
bind_key("n", "<leader>fe", ":Telescope file_browser<CR>")
bind_key('n', '<leader>n', ':NvimTreeToggle<CR>')

bind_key('n', '<leader>o', ':edit $MYVIMRC<CR>')

vim.api.nvim_create_user_command("Gigi", function(args)
  print("Hello there Radu " .. vim.inspect(args))
end, {})
>>>>>>> d3a57e3 (nvim: basic init)
