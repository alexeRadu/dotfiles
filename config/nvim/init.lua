local fn  = vim.fn
local api = vim.api
local g   = vim.g
local o   = vim.o

function pp(var)
    vim.pretty_print(var)
end

function bind_key(mode, key, result)
	vim.api.nvim_set_keymap(mode, key, result, {noremap = true, silent = true})
end

local function pkg_config(name, config)
    local status_ok, pkg = pcall(require, name)
    if not status_ok then
        vim.notify(string.format("Package '%s' unable to load", name), vim.log.levels.DEBUG)
        return
    end

    pkg.setup(config)
    -- vim.notify(string.format("Package '%s' configured", name), vim.log.levels.INFO)
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

-- disable netrw
g.loaded = 1
g.loaded_netrwPlugin = 1

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

    use {'nvim-telescope/telescope-file-browser.nvim'}
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

for file, type in vim.fs.dir("~/.config/nvim/lua/packages") do
    local _, _, pkgname = string.find(file, '([%w_-]+).lua$')

    if pkgname then
        local pkg = require("packages/" .. pkgname)
        pkg_config(pkgname, pkg.config)
    end
end

pkg_config('telescope', {
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
})

require("telescope").load_extension "file_browser"

if bash_exec('printenv | grep WSL')  == '' then
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
