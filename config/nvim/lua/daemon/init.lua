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
    local name    = o.name
    local bufname = "Daemon[" .. name .. "]"
    local daemon  = find_daemon_by_name(name)

    if daemon ~= nil then
        return
    end

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
        return
    end

    M.daemons[#M.daemons + 1] = {
        name    = name,
        bufname = bufname,
        job     = job,
        stopped = true,
    }
end

function M.start(name)
    local daemon = find_daemon_by_name(name)
    if daemon == nil then
        return
    end

    if daemon and daemon.stopped then
        local buf = vim.api.nvim_create_buf(true, true);
        vim.api.nvim_buf_set_name(buf, daemon.bufname)
        daemon.buffer = buf

        daemon.job:start()
        daemon.stopped = false
    end
end

function M.stop(name)
    local daemon = find_daemon_by_name(name)
    if daemon == nil then
        return
    end

    if daemon and not daemon.stopped then
        local uv = vim.loop
        uv.kill(daemon.job.pid, uv.constants.SIGTERM)
        daemon.stopped = true
        vim.api.nvim_buf_delete(daemon.buffer, {})
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
