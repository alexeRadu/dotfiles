local M = {}

M.disable = true
M.post_setup = function()
    local dap = require('dap')

    -- for debugging purposes
    dap.set_log_level('TRACE')

    dap.configurations.c = {
        {
            type = "cppdbg",
            name = "Launch CPP",
            request = "launch",
            program = "/home/radu/code/test/build/test",
        }
    }

    dap.configurations.cpp = {
        {
            type = "cppdbg",
            name = "Attach CPP",
            request = "launch",
            program = "~/work/ot-nxp/build_rw612/bin/ot-cli-rw612.elf"
            -- program = "~/work/ot-nxp/build_rw612/bin/ot-br-rw612.elf"
        }
    }

    dap.adapters.cppdbg = {
        type = 'executable',
        command = '/home/radu/code/binutils-gdb/arm-none-eabi/bin/arm-none-eabi-gdb',
        args = { '-i', 'dap', '-ex', 'target remote localhost:2331'},
    }

    -- vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
    -- vim.keymap.set('n', '<F9>', function() require('dap').toggle_breakpoint() end)
    -- vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
    -- vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
    -- vim.keymap.set('n', '<S-F11>', function() require('dap').step_out() end)
end

return M
