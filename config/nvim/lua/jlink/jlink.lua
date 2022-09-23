local log = require('plenary').log.new({
    plugin = 'jlink',
    level  = 'debug',
    -- use_console = false,
})

local jlink_path = '/mnt/c/JLink/JLink/JLink.exe'
local device_sn = nil

local function jlink_do(cmd_args, action_factory)
    local cmd = {jlink_path}

    for _, arg in ipairs(cmd_args) do
        cmd[#cmd + 1] = arg
    end

    log.debug(string.format("Started job '%s': ", table.concat(cmd, ' ')))

    return vim.fn.jobstart(cmd, {
        stdout_buffered = false,
        stderr_buffered = false,
        on_stdout = action_factory(),
        on_stderr = function(_, data)
            log.debug(table.concat(data, ' '))
        end,
        on_exit = function(_, data)
            log.debug("Job finished")
        end,
    })
end

vim.api.nvim_create_user_command("JLinkStart", function()
    if not device_sn then
        local sn_list = {}

        local jobid = jlink_do({"-CommandFile", "show-emu-list.jlink"}, function()
            return function (_, data)
                for _, line in ipairs(data) do
                    if line and line ~= "" then
                        local sn = string.match(line, "Serial number: (%d+),")
                        if sn then
                            sn_list[#sn_list + 1] = sn
                        end
                    end
                end
            end
        end)

        vim.fn.jobwait({ jobid })

        vim.ui.select(sn_list, {
            prompt = 'Select device interface',
        }, function(sn)
            device_sn = sn
        end)
    end

    cmd = {
        "-USB", device_sn,
        "-If", "SWD",
        "-Device", "RW610",
        "-Speed", "4000",
        "-AutoConnect", "1",
        "-CommandFile", "load-bin.jlink"
    }

    jlink_do(cmd, function()
        local output_buf = vim.api.nvim_create_buf(true, false)

        local function append_data(_, data)
            if data then
                vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, data)
            end
        end

        return append_data
    end)
end, {})
