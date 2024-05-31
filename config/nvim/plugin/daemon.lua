vim.api.nvim_create_user_command("DaemonStart", function(args)
    require("daemon").start(args.args)
end, {
    nargs = 1,
    complete = function()
        local results = {}
        local daemons = require("daemon").daemons

        for name, daemon in pairs(daemons) do
            if daemon.job == nil then
                results[#results + 1] = name
            end
        end

        return results
    end
})

vim.api.nvim_create_user_command("DaemonStop", function(args)
    require("daemon").stop(args.args)
end, {
    nargs = 1,
    complete = function()
        local results = {}
        local daemons = require("daemon").daemons

        for name, daemon in pairs(daemons) do
            if daemon.job ~= nil then
                results[#results + 1] = name
            end
        end

        return results
    end
})

vim.api.nvim_create_user_command("DaemonList", function()
    local daemons = require("daemon").daemons

    for name, daemon in pairs(daemons) do
        local state = "started"
        if daemon.job == nil then
            state = "stopped"
        end

        print(name .. "[" .. state .. "]")
    end
end, { nargs = 0, })

local daemon_exit_group = vim.api.nvim_create_augroup("DaemonExitGroup", {clear = true})
vim.api.nvim_create_autocmd("ExitPre", {
    group = daemon_exit_group,
    callback = function()
        require("daemon").killall()
    end
})
