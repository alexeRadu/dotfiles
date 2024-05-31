local Job = require("plenary").job

local M = {}

M.daemons = {}

local on_output = vim.schedule_wrap(function(err, line, job)
    vim.api.nvim_buf_set_lines(job.buffer, -1, -1, false, {line})
end)

local on_exit = vim.schedule_wrap(function(job, code, signal)
    vim.api.nvim_buf_delete(job.buffer, {})
end)

function M.create(o)
    local daemon  = M.daemons[o.name]
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

    M.daemons[o.name] = {
        name = o.name,
        opts = o
    }
end

function M.start(name)
    local daemon = M.daemons[name]
    if daemon == nil or daemon.job ~= nil then
        return
    end

    local job = Job:new(daemon.opts)
    if not job then
        return
    end

    local buf = vim.api.nvim_create_buf(true, true);
    vim.api.nvim_buf_set_name(buf, "Daemon[" .. name .. "]")

    job:start()
    job.buffer = buf
    daemon.job = job
end

function M.stop(name)
    local daemon = M.daemons[name]
    if not daemon or not daemon.job then
        return
    end

    -- Kill the Job and delete the buffer
    vim.loop.kill(daemon.job.pid, vim.loop.constants.SIGTERM)
    -- vim.api.nvim_buf_delete(daemon.job.buffer, {})
    daemon.job = nil
end

function M.killall()
    for name, _ in ipairs(M.daemons) do
        M.stop(name)
    end
end


return M
