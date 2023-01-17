local api = vim.api
local g   = vim.g
local o   = vim.o

local function pkg_config(name, config, post_setup)
    local status_ok, pkg = pcall(require, name)
    if not status_ok then
        vim.notify(string.format("Package '%s' unable to load", name), vim.log.levels.DEBUG)
        return
    end

    pkg.setup(config)
    -- vim.notify(string.format("Package '%s' configured", name), vim.log.levels.INFO)

    if post_setup and type(post_setup) == "function" then
        post_setup()
    end
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
vim.opt.listchars = { tab = '» ', trail = '·' }
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

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

require('packer').startup(function(use)
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

	use {'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    use {'nvim-treesitter/playground'}
	use {'neovim/nvim-lspconfig'}
	use {'williamboman/nvim-lsp-installer'}
    use {'hrsh7th/nvim-cmp'}
    use {'hrsh7th/cmp-nvim-lsp'}
    use {'hrsh7th/cmp-buffer'}
    use {'hrsh7th/cmp-path'}
	use {'simrat39/symbols-outline.nvim'}
    use {'lukas-reineke/indent-blankline.nvim'}
    use {'navarasu/onedark.nvim'}
    use {'numToStr/Comment.nvim'}
    use {'theHamsta/nvim-semantic-tokens'}
    use {'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async'}
    use {'lewis6991/gitsigns.nvim'}
    use {'ggandor/leap.nvim'}

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
        pkg_config(pkgname, pkg.config, pkg.post_setup)
    end
end

pkg_config('telescope', {
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
})

require("telescope").load_extension "file_browser"

require('nvim-treesitter.configs').setup {
    ensure_installed = {
        "c",
        "cpp",
        "lua",
        "vim",
        "python",
        "bash",
        "cmake",
        "make",
        "ninja",
        "diff",
        "gitattributes",
        "gitcommit",
        "json",
        "markdown",
        "java",
        "javascript",
        "typescript",
        "html",
        "http",
        "css",
    },
    auto_install = true,
    sync_install = false,

    highlight = {
      enable = true,
      -- use_languagetree = true,
      -- additional_vim_regex_highlighting = false,
    },

    indents = {
        enable = true,
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

local on_attach = function(client, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, {
            noremap = true,
            buffer = bufnr,
            silent = true,
            desc = desc,
        })
    end

    api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('gd', vim.lsp.buf.definition, 'Goto Definition')
    nmap('K', vim.lsp.buf.hover)
    nmap('gi', vim.lsp.buf.implementation)

    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end)

    nmap('<leader>dn', vim.diagnostic.goto_next)
    nmap('<leader>dp', vim.diagnostic.goto_prev)
    nmap('<leader>dl', "<cmd>Telescope diagnostics<cr>")

    nmap('<leader>rn', vim.lsp.buf.rename)
    nmap('<leader>ca', vim.lsp.buf.code_action)

    -- TODO: this should be removed for neovim 0.9 since 'semanticTokens' functionatlity
    -- will be included in the default neovim
    local caps = client.server_capabilities
    if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
        local augroup = vim.api.nvim_create_augroup("SemanticTokens", {})
        vim.api.nvim_create_autocmd("TextChanged", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.semantic_tokens_full()
            end,
        })

        vim.lsp.buf.semantic_tokens_full()
    end
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local sumneko_cmd = nil
if os.getenv("NAME") == "NXL49106" then
    sumneko_cmd = { "/home/" .. os.getenv("USER") .. "/code/lua-language-server/bin/lua-language-server" }
elseif vim.fn.system('hostname') == 'asr\n' then
    sumneko_cmd = { "/home/" .. os.getenv("USER") .. "/lua-language-server/bin/lua-language-server" }
end

vim.api.nvim_set_hl(0, "LspComment", { link = "Comment" })

require('lspconfig').sumneko_lua.setup({
    cmd = sumneko_cmd,
    on_attach = on_attach,
    capabilities = capabilities,
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

local clangd_cmd = { "clangd" }
if os.getenv("NAME") == "NXL49106" then
    clangd_cmd = { "/mnt/c/tmp/clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04/bin/clangd" }
end

require('lspconfig').clangd.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        cmd = clangd_cmd,
    }
}

require('lspconfig').pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
    }
}

require('nvim-semantic-tokens').setup {
    preset = "default",
    highlighters = { require 'nvim-semantic-tokens.table-highlighter' },
}

-- TODO: install LuaSnip and luasnip-cmp
local cmp = require('cmp')

cmp.setup {
    mapping = cmp.mapping.preset.insert {
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm { select = true },
    },
    sources = cmp.config.sources ({
        { name = 'nvim_lsp' },
    }, {
        { name = 'buffer' },
    }),
}

vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
})

require('gitsigns').setup()

require('leap').add_default_mappings()

vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { silent = true })
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { silent = true })
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { silent = true })
vim.keymap.set("n", "<leader>fe", ":Telescope file_browser<CR>", { silent = true })
vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', { silent = true })

vim.keymap.set('n', '<leader>o', ':edit $MYVIMRC<CR>', { silent = true })
vim.keymap.set('n', '<leader>e', ':luafile %<CR>', { silent = true })

vim.keymap.set('n', '<leader>c', ':Croniker<CR>', { silent = true })

vim.keymap.set('n', '<leader>m', ':lua require("utils").show_loaded_packages()<CR>', { silent = true })

vim.keymap.set('n', '<leader>pp', ':lua require("project").list_projects()<CR>', { silent = true })
vim.keymap.set('n', '<leader>pq', ':lua require("project").quit_project()<CR>', { silent = true })

require('utils')
