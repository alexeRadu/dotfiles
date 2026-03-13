vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

-- Basic settings
-- This should come first becase if there are some issues later on with the initialization
-- we still have some settings in place
require "settings"

-- Basic keymaps
-- These mappings should be as close to the top as possible since they are
-- usefull with a vanilla installation of neovim and don't remquire any packages
require "keymaps"

-- open help in a horizontal split
local horizontal_help_split_group = vim.api.nvim_create_augroup("HorizontalHelpSplit", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    command = 'wincmd L',
    group   = horizontal_help_split_group,
    pattern = "help"
})

-- Boostraping the plugin manager
require "lazy-bootstrap"

require("lazy").setup("plugins")


-- Termdebug setup
-- vim.cmd [[packadd termdebug]]

vim.g.termdebug_config = {
    ["command"]    = 'arm-none-eabi-gdb',
    ["use_prompt"] = false,
}

-- Daemon package
require('daemon').setup({})

vim.keymap.set('n', '<F5>',    ':DebugStart<CR>', {silent = true})

local gdb_configs = {
    mcxw71_conn_test_split = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2321,
        select     = "usb=1066710819",
        filename   ="/home/radu/work/workspace/mcuxsdk/build/mcxw71evk/conn_test_split/15_4_connectivity_test_bm.elf"
    },
    mcxw71_ot_cli = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2321,
        select     = "usb=1066710819",
        filename   ="/home/radu/work/workspace/ot-nxp/build_mcxw71/bin/ot-cli-ftd.elf"
    },
    mcxw71_zboss_cli = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2321,
        select     = "usb=1066710819",
        filename   ="/home/radu/work/nxp_zephyr_zboss/build/mcxw71/cli_nxp_zed/zephyr/zephyr.elf"
    },
    mcxw71_zboss_on_off = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2321,
        select     = "usb=1066710819",
        filename   ="/home/radu/work/nxp_zephyr_zboss/build/mcxw71/on_off_switch_zed/zephyr/zephyr.elf"
    },
    mcxw71_zephyr_echo_server = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45Z41083",
        interface  = "SWD",
        port       = 2321,
        select     = "usb=1066710819",
        filename   ="/home/radu/work/zephyrproject/zephyr/build/frdm_mcxw71/echo_server/zephyr/zephyr.elf"
    },
    mcxw71_nbu_dyn_mac = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45B41Z83_NBU",
        interface  = "SWD",
        port       = 2382,
        select     = "usb=1066710819",
        filename   ="/home/radu/work/workspace/mcuxsdk/build/mcxw71evk/nbu_dyn_mac_split/nbu_ble_15_4_dyn_mac_split.elf"
    },
    mcxw71_nbu = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW45B41Z83_NBU",
        interface  = "SWD",
        port       = 2361,
        select     = "usb=1066710819",
        filename   = "/home/radu/work/workspace/mcuxsdk/build/mcxw71evk/nbu_15_4/nbu_15_4.elf"
    },
    mcxw72_conn_test_split = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2321,
        select     = "usb=1061068817",
        filename   ="/home/radu/work/workspace/mcuxsdk/build/mcxw72evk/conn_test_split/15_4_connectivity_test_bm_cm33_core0.elf"
    },
    mcxw72_conn_test_standalone = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2321,
        select     = "usb=1061068817",
        filename   ="/home/radu/work/workspace/mcuxsdk/build/mcxw72evk/conn_test_standalone/15.4_connectivity_test_bm_cm33_core0.elf"
    },
    mcxw72_ot_cli = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2321,
        select     = "usb=1061068817",
        filename   ="/home/radu/work/workspace/ot-nxp/build_mcxw72/bin/ot-cli-ftd.elf"
    },
    mcxw72_dual_app = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_0",
        interface  = "SWD",
        port       = 2331,
        select     = "usb=1064975873",
        filename   = "/home/radu/work/workspace/ot-nxp/build_mcxw72/ot_cli_ftd_ble_shell/bin/ot-cli-ftd-ble-shell-mcxw72.elf"
    },
    mcxw72_nbu_dyn = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_1",
        interface  = "SWD",
        port       = 2372,
        select     = "usb=1061068817",
        -- select     = "usb=1064975873",
        filename   = "/home/radu/work/workspace/mcuxsdk/build/mcxw72evk/nbu_dyn_phy_split/nbu_ble_15_4_dyn_phy_split_cm33_core1.elf",
    },
    mcxw72_nbu = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW47B42ZB7_M33_1",
        interface  = "SWD",
        port       = 2361,
        select     = "usb=1061068817",
        filename   = "/home/radu/work/workspace/mcuxsdk/build/mcxw72evk/nbu_15_4/nbu_15_4_cm33_core1.elf"
    },
    kw43_conn_test_split = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW43B43ZC7",
        interface  = "SWD",
        port       = 2741,
        select     = "usb=601007884",
        filename   = "/home/radu/work/workspace/mcuxsdk/build/kw43evk/conn_test_split/15_4_connectivity_test_bm.elf"
    },
    kw43_dual_app = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW43B43ZC7",
        interface  = "SWD",
        port       = 2741,
        select     = "usb=601007884",
        filename   = "/home/radu/work/workspace/ot-nxp/build_mcxw30/ot_cli_ftd_ble_shell/bin/ot-cli-ftd-ble-shell-mcxw30.elf"
    },
    kw43_nbu = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW43B43ZC7_NBU",
        interface  = "SWD",
        port       = 2362,
        select     = "usb=601007884",
        filename   = "/home/radu/work/workspace/mcuxsdk/build/kw43evk/nbu_15_4/nbu_15_4.elf"
    },
    kw43_nbu_dyn = {
        command    = "/opt/SEGGER/JLink/JLinkGDBServerCLExe",
        device     = "KW43B43ZC7_NBU",
        interface  = "SWD",
        port       = 2361,
        select     = "usb=601007884",
        filename   = "/home/radu/work/workspace/mcuxsdk/build/kw43evk/nbu_dyn_phy_split/nbu_ble_15_4_dyn_phy_split.elf"
    },
}

local current_gdb_config = nil

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

-- vim.cmd("colorscheme nightfox")
