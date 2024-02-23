vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

-- disable netrw
vim.g.loaded             = 1
vim.g.loaded_netrwPlugin = 1

vim.o.background     = 'dark'
vim.o.errorbells     = false
vim.o.number         = true
vim.o.relativenumber = true
vim.o.termguicolors  = true
vim.o.list           = true
vim.o.splitbelow     = true
vim.o.splitright     = true
vim.o.cursorline     = true
vim.o.autoread       = true
vim.o.foldcolumn     = '1'
vim.o.foldlevel      = 99
vim.o.foldlevelstart = 99
vim.o.foldenable     = true
vim.opt.listchars    = { tab = '» ', trail = '·' }
vim.opt.completeopt  = { 'menu', 'menuone', 'noselect' }

-- These mappings should be as close to the top as possible since they are
-- usefull with a vanilla installation of neovim and don't remquire any packages
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<leader>i', ':edit $MYVIMRC<CR>', { silent = true })
vim.keymap.set('n', '<leader>e', ':luafile %<CR>', { silent = true })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { silent = true })
vim.keymap.set('n', '<leader>h', ':help ', { silent = false })

-- open help in a horizontal split
local horizontal_help_split_group = vim.api.nvim_create_augroup("HorizontalHelpSplit", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    command = 'wincmd L',
    group   = horizontal_help_split_group,
    pattern = "help"
})

-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    is_bootstrap = true
    vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomas/packer.nvim', install_path }
    vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
    use {'wbthomason/packer.nvim'}
    use {'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use {'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make',
        cond = vim.fn.executable 'make' == 1,
    }
    use {'kyazdani42/nvim-tree.lua',
        requires = {'kyazdani42/nvim-web-devicons'}
    }
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
    use {'lukas-reineke/indent-blankline.nvim',
        main="ibl",
        opt={}
    }
    use {'navarasu/onedark.nvim'}
    use {'numToStr/Comment.nvim'}
    use {'theHamsta/nvim-semantic-tokens'}
    use {'kevinhwang91/nvim-ufo',
        requires = 'kevinhwang91/promise-async'
    }
    use {'lewis6991/gitsigns.nvim'}
    use {'ggandor/leap.nvim'}
    use {'mfussenegger/nvim-dap'}
    use {'rcarriga/nvim-dap-ui'}

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

-- local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
-- vim.api.nvim_create_autocmd('BufWritePost', {
--     command = 'source <afile> | PackerCompile',
--     group = packer_group,
--     pattern = vim.fn.expand '$MYVIMRC',
-- })

local pkg_config = function(name, config, post_setup)
    local status_ok, pkg = pcall(require, name)
    if not status_ok then
        vim.notify(string.format("Package '%s' unable to load", name), vim.log.levels.DEBUG)
        return
    end

    if config then
        pkg.setup(config)
        -- vim.notify(string.format("Package '%s' configured", name), vim.log.levels.INFO)
    end

    if post_setup and type(post_setup) == "function" then
        post_setup()
        -- vim.notify(string.format("Package '%s' post_setup", name), vim.log.levels.INFO)
    end
end

for file, type in vim.fs.dir("~/.config/nvim/lua/packages") do
    local _, _, pkgname = string.find(file, '([%w_-]+).lua$')

    if pkgname then
        local pkg = require("packages/" .. pkgname)

        if pkg.disable == nil or pkg.disable == false then
            pkgname = vim.F.if_nil(pkg.name, pkgname)

            pkg_config(pkgname, pkg.config, pkg.post_setup)
        end
    end
end

-- Termdebug setup
vim.cmd [[packadd termdebug]]

vim.g.termdebug_config = {
    ["command"]    = 'arm-none-eabi-gdb',
    ["use_prompt"] = false,
}

vim.keymap.set('n', '<F5>',    ':DebugStart<CR>', {silent = true})

local cmd  = "/home/radu/work/JLink/JLink/JLinkGDBServerCLExe"
local args  = {"-device", "RW610", "-if", "SWD", "-nogui"}
require('daemon').create {
    name    = 'GDB',
    command = cmd,
    args    = args,
}

vim.api.nvim_create_user_command('DebugStart', function()
    require('daemon').start('GDB')
    vim.cmd ':TermdebugCommand ./build_rw612/rw612_ot_br_wifi/bin/ot-br-rw612.elf'
    vim.fn.TermDebugSendCommand('target remote localhost:2331')

    -- close gdb window
    vim.cmd ':Gdb'
    vim.cmd ':q'

    -- close program window
    vim.cmd ':Program'
    vim.cmd ':q'

    vim.keymap.set('n', '<F5>',    ':Continue<CR>',  {silent = true})
    vim.keymap.set('n', '<F6>',    ':Stop<CR>',      {silent = true})
    vim.keymap.set('n', '<F9>',    ':Break<CR>',     {silent = true})
    vim.keymap.set('n', '<F10>',   ':Over<CR>',      {silent = true})
    vim.keymap.set('n', '<F11>',   ':Step<CR>',      {silent = true})
    vim.keymap.set('n', '<F12>',   ':DebugStop<CR>', {silent = true})
end, {nargs = 0})

vim.api.nvim_create_autocmd("User", {
    pattern = "TermdebugStopPost",
    callback = function(ev)
        print("Debugging stopped")

        for _, buf in pairs(vim.api.nvim_list_bufs()) do
            local bufname = vim.api.nvim_buf_get_name(buf)
            if string.find(bufname, "^term:") ~= nil then
                -- TODO: maybe refine this condition
                vim.api.nvim_buf_delete(buf, {force = true})
            end
        end
    end
})

vim.api.nvim_create_user_command('DebugStop', function()
    vim.fn.TermDebugSendCommand('exit')
    vim.fn.TermDebugSendCommand('y')

    require('daemon').stop('GDB')

    vim.keymap.set('n', '<F5>',    ':DebugStart<CR>', {silent = true})
    vim.keymap.del('n', '<F6>')
    vim.keymap.del('n', '<F9>')
    vim.keymap.del('n', '<F10>')
    vim.keymap.del('n', '<F11>')
    vim.keymap.del('n', '<F12>')
end, {nargs = 0})


-- vim.keymap.set('n', '<leader>c', ':Croniker<CR>', { silent = true })
-- vim.keymap.set('n', '<leader>m', ':lua require("utils").show_loaded_packages()<CR>', { silent = true })
-- vim.keymap.set('n', '<leader>pp', ':lua require("project").list_projects()<CR>', { silent = true })
-- vim.keymap.set('n', '<leader>pq', ':lua require("project").quit_project()<CR>', { silent = true })
