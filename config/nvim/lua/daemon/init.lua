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

local on_output = vim.schedule_wrap(function(err, line, job)
    local name = job.name
    local daemon = find_daemon_by_name(name)
    if daemon and daemon.job ~= nil then
        vim.api.nvim_buf_set_lines(daemon.buffer, -1, -1, false, {line})
    end
end)

local on_exit = vim.schedule_wrap(function(code, signal)
end)

function M.create(o)
    local daemon  = find_daemon_by_name(o.name)
    if daemon ~= nil then
        return
    end

    -- force some defaults
    o.interactive      = false
    o.detached         = true
    o.enable_recording = false

    -- add specific handlers
    o.enable_handlers = true
    o.on_stdout = on_output
    o.on_stderr = on_output
    o.on_exit   = on_exit

    M.daemons[#M.daemons + 1] = {
        name = o.name,
        opts = o
    }
end

function M.start(name)
    local daemon = find_daemon_by_name(name)
    if daemon == nil or daemon.job ~= nil then
        return
    end

    local job = Job:new(daemon.opts)
    if not job then
        return
    end

    local buf = vim.api.nvim_create_buf(true, true);
    vim.api.nvim_buf_set_name(buf, "Daemon[" .. name .. "]")

    daemon.job:start()

    daemon.buffer = buf
    daemon.job = job
end

function M.stop(name)
    local daemon = find_daemon_by_name(name)
    if daemon == nil or daemon.job == nil then
        return
    end

    vim.loop.kill(daemon.job.pid, uv.constants.SIGTERM)
    vim.api.nvim_buf_delete(daemon.buffer, {})
    daemon.job = nil
    daemon.buffer = nil
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
