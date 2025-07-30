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
vim.opt.listchars    = { tab = '» ', trail = '·' }
vim.opt.completeopt  = { 'menu', 'menuone', 'noselect' }

-- These mappings should be as close to the top as possible since they are
-- usefull with a vanilla installation of neovim and don't remquire any packages
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<leader>i', ':edit $MYVIMRC<CR>', { silent = true })
vim.keymap.set('n', '<leader>e', ':luafile %<CR>', { silent = true })
vim.keymap.set('n', '<leader>h', ':help ', { silent = false })
vim.keymap.set('n', '<C-s>', ':w<CR>', { silent = false })

-- Keybindings for navigating/creating windows
vim.keymap.set('n', '<C-h>', '<C-w>h', { silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { silent = true })
vim.keymap.set('n', '<C-w>h', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-w>l', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-w>j', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-w>k', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-w>h', ':leftabove vsplit<CR>', { silent = true })
vim.keymap.set('n', '<C-w>l', ':rightbelow vsplit<CR>', { silent = true })
vim.keymap.set('n', '<C-w>j', ':rightbelow split<CR>', { silent = true })
vim.keymap.set('n', '<C-w>k', ':leftabove split<CR>', { silent = true })

-- Moving in insert mode
vim.keymap.set('i', '<C-h>', '<C-c>', { silent = true })
vim.keymap.set('i', '<C-j>', '<C-c>lj', { silent = true })
vim.keymap.set('i', '<C-k>', '<C-c>lk', { silent = true })
vim.keymap.set('i', '<C-l>', '<C-c>ll', { silent = true })

-- Terminal keybindings
vim.keymap.set('t', '<C-z>', [[<C-\><C-n>]], { silent = true })
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { silent = true})
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { silent = true})
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { silent = true})
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { silent = true})

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
    vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
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

    -- themes
    use {'navarasu/onedark.nvim'}
    use {'catppuccin/nvim', as = "catppuccin" }
    use {'EdenEast/nightfox.nvim'}
    use {'rebelot/kanagawa.nvim'}
    use {'folke/tokyonight.nvim'}
    use {'scottmckendry/cyberdream.nvim'}
    use {'rose-pine/neovim'}

    use {'numToStr/Comment.nvim'}
    use {'kevinhwang91/nvim-ufo',
        requires = 'kevinhwang91/promise-async'
    }
    use {'lewis6991/gitsigns.nvim'}
    use {'ggandor/leap.nvim'}
    use {'mfussenegger/nvim-dap'}
    use {'rcarriga/nvim-dap-ui'}
    use {'rbong/vim-flog',
        requires = {
            'tpope/vim-fugitive'
        }
    }

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

for file, _ in vim.fs.dir("~/.config/nvim/lua/packages") do
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

local gdb_configs = {
    mcxw72_mac_fsci_bb = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2341,
        select     = "usb=1067654650",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/mcxw72evk/mac_fsci_bb/mac_fsci_black_box_split_cm33_core0.elf",
    },
    mcxw71_mac_fsci_bb = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2341,
        select     = "usb=1066710819",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/mcxw71evk/mac_fsci_bb/mac_fsci_black_box_split.elf",
    },
    mcxw72_host = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2331,
        filename   = "/home/radu/work/ot-nxp/build_mcxw72/bin/ot-cli-ftd.elf",
    },
    mcxw72_nbu = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_1",
        interface  = "SWD",
        port       = 2361,
        -- select     = "usb=1069060107",
        select     = "usb=1067654650",
        -- filename   = "/home/radu/work/MCZB-2473/mcu-sdk-2.0/middleware/wireless/ieee-802.15.4/boards/mcxw72/nbu_15_4/bm/iar/Debug/Exe/nbu_15_4.out"
        filename   = "/home/radu/work/sdk-next/mcu-sdk-3.0/middleware/wireless/ieee-802.15.4_private/boards/mcxw72/nbu_ble_15_4_dyn/Debug/Exe/nbu_ble_15_4_dyn.out"
    },
    mcxw72_ot = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2371,
        select     = "usb=1069060107",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/ot-nxp/build_mcxw72/bin/ot-cli-ftd.elf",
    },
    mcxw72_ot_loc_reader = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2381,
        select     = "usb=1069060107",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/ot-nxp/build_mcxw72/ot_cli_ftd_ble_loc_reader/bin/ot-cli-ftd-ble-loc-reader-mcxw72.elf",
    },
    k32w1_15_4_controller = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2351,
        select     = "usb=1063040867",
        filename   = "/home/radu/work/MCZB-2274/mcu-sdk-2.0/middleware/wireless/ieee-802.15.4/ieee_802_15_4/examples/controller/build/15.4-controller.elf",
    },
    k32w1_15_4_conn_test = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2351,
        -- select     = "usb=1067654650",
        -- select     = "usb=1063040867",
        select     = "usb=1066710819",
        filename   = "./Debug/frdmmcxw71_15_4_connectivity_test_bm.axf",
    },
    mcxw71_ot = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2381,
        select     = "usb=1066710819",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/ot-nxp/build_mcxw71/bin/ot-cli-ftd.elf",
    },
    k32w1_nbu = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2391,
        select     = "usb=1066710819",
        -- select     = "usb=1066710819",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/middleware/wireless/ieee-802.15.4_private/boards/k32w1_mcxw71/nbu_ble_15_4_dyn/Debug/Exe/nbu_ble_15_4_dyn.out"
    },
    mcxw72_15_4_controller = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        -- device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2341,
        -- select     = "usb=1067654650",
        select     = "usb=1069060107",
        filename   = "/home/radu/work/MCZB-2274/mcu-sdk-2.0/middleware/wireless/ieee-802.15.4/ieee_802_15_4/examples/controller/build/15.4-controller.elf",
    },
    mcxw72_15_4_conn_test = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2341,
        select     = "usb=1067654650",
        filename   ="/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/mcxw72evk/conn_test/15.4_connectivity_test_bm_cm33_core0.elf"
    },
    mcxw72_lighting_app = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2341,
        select     = "usb=1069060107",
        -- select     = "usb=1067654650",
        filename   = "/home/radu/work/connectedhomeip/examples/lighting-app/nxp/mcxw72/out/debug/chip-mcxw72-light-example.elf"
    },
    mcxw72_lock_app = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2341,
        select     = "usb=1069060107",
        filename   = "/home/radu/work/connectedhomeip/examples/lock-app/nxp/mcxw72/out/debug/chip-mcxw72-lock-example"
    },
    mcxw71_lighting_app = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2341,
        select     = "usb=1066710819",
        filename   = "/home/radu/work/connectedhomeip/examples/lighting-app/nxp/mcxw71/out/debug/chip-mcxw71-light-example.elf"
    },
    mcxw72_loc_reader = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2341,
        select     = "usb=1069060107",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/loc_reader_bm_cm33_core0.elf"
    },
    kw43_15_4_conn_test = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW43B43ZC7",
        interface  = "SWD",
        port       = 2741,
        select     = "usb=601007884",
        -- filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/conn_test/iar/15_4_connectivity_test_bm.out"
        -- filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/kw43evk/conn_test/15_4_connectivity_test_bm.elf"
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/kw43evk/conn_test/15.4_connectivity_test_bm.elf"
    },
    kw43_nbu = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW43B43ZC7_NBU",
        interface  = "SWD",
        port       = 2361,
        select     = "usb=601007884",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/kw43evk/nbu_15_4/nbu_15_4.elf"
        -- filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/kw43evk/nbu_15_4/iar/nbu_15_4.out"
    },
    kw43_nbu_dyn = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW43B43ZC7_NBU",
        interface  = "SWD",
        port       = 2361,
        select     = "usb=601007884",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/middleware/wireless/ieee-802.15.4_private/boards/mcxw30/nbu_ble_15_4_dyn/Debug/Exe/nbu_ble_15_4_dyn.out"
    },
    kw43_15_4_ot = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW43B43ZC7",
        interface  = "SWD",
        port       = 2741,
        select     = "usb=601007884",
        -- filename   = "/home/radu/work/sdk/mcuxsdk-workspace/mcuxsdk/build/conn_test/iar/15_4_connectivity_test_bm.out"
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/ot-nxp/build_mcxw30/bin/ot-cli-ftd.elf"
    },
    kw43_15_4_ot_ble_shell = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW43B43ZC7",
        interface  = "SWD",
        port       = 2741,
        select     = "usb=601007884",
        filename   = "/home/radu/work/sdk/mcuxsdk-workspace/ot-nxp/build_mcxw30/ot_cli_ftd_ble_shell/bin/ot-cli-ftd-ble-shell-mcxw30.elf"
    },
}

local current_gdb_config = nil
-- local current_gdb_config = "k32w1_15_4_controller"
-- local current_gdb_config = "mcxw72_host"

local start_gdb = function()
    print("current_gdb_config: " .. current_gdb_config)
    if current_gdb_config == nil then
        warn('no gdb config chosen')
        return
    end
    local config = gdb_configs[current_gdb_config]

    require('daemon').start(current_gdb_config, config)

    vim.cmd(":TermdebugCommand " .. config.filename)
    vim.fn.TermDebugSendCommand('target remote localhost:' .. config.port)
    vim.fn.TermDebugSendCommand('set print pretty')

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
end

vim.api.nvim_create_user_command('DebugStart', function()
    if current_gdb_config == nil then
        local available_configs = {}
        for config_name, _ in pairs(gdb_configs) do
            available_configs[#available_configs + 1] = config_name
        end

        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values

        pickers.new({
            require('telescope.themes').get_dropdown({}),
        }, {
            prompt_title = "Select GDB config",
            finder = finders.new_table({
                results = available_configs
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
                local actions = require 'telescope.actions'
                local action_state = require "telescope.actions.state"

                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()

                     -- TODO: handle case where nothing has been selected
                     current_gdb_config = selection[1]

                     start_gdb()
                end)
                return true
            end,
        }):find()

        -- vim.ui.select(available_configs, { prompt = "Select GDB config: " }, function(choice)
        --     if current_gdb_config then
        --         print("Gdb already running")
        --         return
        --     else
        --         current_gdb_config = choice
        --     end
        -- end)
    else
        start_gdb()
    end

end, {nargs = 0})

vim.api.nvim_create_autocmd("User", {
    pattern = "TermdebugStopPost",
    callback = function(_)
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

vim.cmd("colorscheme nightfox")
