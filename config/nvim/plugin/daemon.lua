vim.api.nvim_create_user_command("DaemonStart", function(args)
    require("daemon").start(args.args)
end, {
    nargs = 1,
    complete = function()
        local results = {}
        local daemons = require("daemon").daemons

        for _, daemon in ipairs(daemons) do
            if daemon.stopped then
                results[#results + 1] = daemon.name
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

        for _, daemon in ipairs(daemons) do
            if not daemon.stopped then
                results[#results + 1] = daemon.name
            end
        end

        return results
    end
})

vim.api.nvim_create_user_command("DaemonList", function()
    local daemons = require("daemon").daemons

    if #daemons == 0 then
        print("No daemons found")
        return
    end

    for _, daemon in ipairs(daemons) do
        local state = "started"
        if daemon.stopped then
            state = "stopped"
        end

        print(daemon.name .. "[" .. state .. "]")
    end
end, {
    nargs = 0,
})

local daemon_exit_group = vim.api.nvim_create_augroup("DaemonExitGroup", {clear = true})
vim.api.nvim_create_autocmd("ExitPre", {
    group = daemon_exit_group,
    callback = function()
        require("daemon").killall()
    end
})
