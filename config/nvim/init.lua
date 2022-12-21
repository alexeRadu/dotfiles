local fn  = vim.fn
local api = vim.api
local g   = vim.g
local o   = vim.o

function pp(var)
    vim.pretty_print(var)
end

function bind_key(mode, key, result)
	api.nvim_set_keymap(mode, key, result, {noremap = true, silent = true})
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

local function bash_exec(cmd)
  local handle = io.popen(cmd)
  if not handle then
      return
  end
  local result = handle:read("*a")
  handle:close()

  return result
end

g.mapleader      = ' '
g.maplocalleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

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

-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    is_bootstrap = true
    vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomas/packer.nvim', install_path }
    vim.cmd [[packadd packer.nvim]]
end

-- disable netrw
g.loaded = 1
g.loaded_netrwPlugin = 1

require('packer').startup(function()
    use {'wbthomason/packer.nvim'}

	use { 'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        requires = { 'nvim-lua/plenary.nvim' }
    }

    use { 'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make',
        cond = vim.fn.executable 'make' == 1,
    }

	use {'kyazdani42/nvim-tree.lua', requires = {'kyazdani42/nvim-web-devicons'}}
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

    if is_bootstrap then
        require('packer').sync()
    end
end)

if is_bootstrap then
    print '=================================='
    print '    Plugins are being installed'
    print '    Wait until Packer completes,'
    print '       then restart nvim'
    print '=================================='
    return
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
    command = 'source <afile> | PackerCompile',
    group = packer_group,
    pattern = vim.fn.expand '$MYVIMRC',
})

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

local on_attach = function(client, bufnr)
    api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local bufopts = {noremap = true, silent = true, buffer = bufnr}

    vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', '<c-]>', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
end

require('lspconfig').sumneko_lua.setup({
    on_attach = on_attach,
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                globals = {'vim'}
            },
            workspace = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                }
            }
        },
    },
})

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
