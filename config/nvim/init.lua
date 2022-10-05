local fn  = vim.fn
local api = vim.api
local g   = vim.g
local o   = vim.o

function bind_key(mode, key, result)
	vim.api.nvim_set_keymap(mode, key, result, {noremap = true, silent = true})
end

function bash_exec(cmd)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()

  return result
end

g.mapleader  = ' '

o.background     = 'dark'
o.errorbells     = false
o.number         = true
o.relativenumber = true
o.termguicolors  = true
o.list           = true
o.splitbelow     = true
o.splitright     = true
o.cursorline     = true
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
    use {'nvim-treesitter/playground'}
	use {'neovim/nvim-lspconfig'}
	use {'williamboman/nvim-lsp-installer'}
	use {'simrat39/symbols-outline.nvim'}
    use {'lukas-reineke/indent-blankline.nvim'}
    use {'lukas-reineke/onedark.nvim'}
    use {'numToStr/Comment.nvim'}
    use {'gaborvecsei/cryptoprice.nvim'}
end)


require('nvim-tree').setup {
    -- TODO: maybe I should just disable this in .vimrc so that
    -- it's not loaded in the first place instead of loading it and then
    -- disabling it
    disable_netrw = true,
    view = {
        adaptive_size = true,
    },
}

if bash_exec('printenv | grep WSL')  == '' then
    -- TODO: setting treesitter on WSL makes quiting nvim very slow -> investigate
    require('nvim-treesitter.configs').setup {
    ensure_installed = {"c", "lua", "python"},
    highlight = {
      enable = true,
      use_languagetree = true,
      additional_vim_regex_highlighting = false,
    },
    playground = {
      enable = true
    },
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = {"BufWrite", "CursorHold"},
    },
}
end
require('indent_blankline').setup {
  show_current_context = true,
  show_current_context_start = true,
  show_end_of_line     = true,
}
require('onedark').setup()
require('Comment').setup()
require('cryptoprice').setup({base_currency = "eur"})

bind_key('n', '<leader>ff', ':Telescope find_files<CR>')
bind_key('n', '<leader>fb', ':Telescope buffers<CR>')
bind_key('n', '<leader>fg', ':Telescope live_grep<CR>')
bind_key("n", "<leader>fe", ":Telescope file_browser<CR>")
bind_key('n', '<leader>n', ':NvimTreeToggle<CR>')

bind_key('n', '<leader>o', ':edit $MYVIMRC<CR>')
bind_key('n', '<leader>e', ':luafile %<CR>')

bind_key('n', '<leader>c', ':Croniker<CR>')

bind_key('n', '<leader>m', ':lua require("utils").show_loaded_packages()<CR>')

bind_key('n', '<leader>pp', ':lua require("project").list_projects()<CR>')
bind_key('n', '<leader>pq', ':lua require("project").quit_project()<CR>')

require('utils')
