local Job = require("plenary").job

local M = {}

M.daemons = {}

local function find_daemon_by_name(name)
    if type(name) ~= "string" then
        return nil
    end

    for _, daemon in ipairs(M.daemons) do
        if daemon.name == name then
            return daemon
        end
    end

    return nil
end

function M.create(o)
    if not o.name or type(o.name) ~= "string" then
        print("Please provide a daemon name")
        return nil
    end
    local name    = o.name
    local bufname = "Daemon[" .. name .. "]"

    for _, daemon in ipairs(M.daemons) do
        if daemon.name == name then
            return
        end
    end

    local buf = vim.api.nvim_create_buf(true, true);
    vim.api.nvim_buf_set_name(buf, bufname)

    local on_output = vim.schedule_wrap(function(err, line, job)
        local daemon = find_daemon_by_name(name)
        if daemon and not daemon.stopped then
            vim.api.nvim_buf_set_lines(daemon.buffer, -1, -1, false, {line})
        end
    end)

    local on_exit = vim.schedule_wrap(function(code, signal)
    end)

    -- force some defaults
    o.interactive      = false
    o.detached         = true
    o.enable_recording = false

    -- add specific handlers
    o.enable_handlers = true
    o.on_stdout = on_output
    o.on_stderr = on_output
    o.on_exit   = on_exit

    local job = Job:new(o)
    if not job then
        print("Unable to create job for " .. o.command)
        vim.api.nvim_buf_delete(buf, {})
    end

    M.daemons[#M.daemons + 1] = {
        name          = name,
        buffer_name   = bufname,
        buffer        = buf,
        job           = job,
        stopped       = true,
    }
end

function M.start(name)
    local daemon = find_daemon_by_name(name)

    if daemon and daemon.stopped then
        daemon.job:start()
        daemon.stopped = false
    end
end

function M.stop(name)
    local daemon = find_daemon_by_name(name)

    if daemon and not daemon.stopped then
        local uv = vim.loop
        uv.kill(daemon.job.pid, uv.constants.SIGTERM)
        daemon.stopped = true
    end
end

function M.killall()
    for _, daemon in ipairs(M.daemons) do
        if not daemon.stopped then
            local uv = vim.loop
            uv.kill(daemon.job.pid, uv.constants.SIGTERM)
            daemon.stopped = true
        end
    end
end


return M
