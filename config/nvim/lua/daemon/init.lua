local Job = require("plenary").job

local M = {}

M.daemons = {}

local on_output = vim.schedule_wrap(function(err, line, job)
    vim.api.nvim_buf_set_lines(job.buffer, -1, -1, false, {line})
end)

local on_exit = vim.schedule_wrap(function(job, code, signal)
    print("Exiting Job")
    -- vim.api.nvim_buf_delete(job.buffer, {})
    M.stop(job.name)
end)

function M.start(name, config)
    local opts = {}

    -- force some defaults
    opts.interactive      = false
    opts.detached         = true
    opts.enable_recording = false

    -- add specific handlers
    opts.enable_handlers = true
    opts.on_stdout = on_output
    opts.on_stderr = on_output
    opts.on_exit   = on_exit

    opts.command = config.command
    opts.args = {
        "-device",
        config.device,
        "-if",
        config.interface,
        "-nogui",
        "-port",
        config.port
    }

    local job = Job:new(opts)
    if not job then
        return
    end

    local buf = vim.api.nvim_create_buf(true, true);
    vim.api.nvim_buf_set_name(buf, "Daemon[" .. name .. "]")

    job:start()
    job.buffer = buf
    job.name = name -- needed when the Job is not able to start

    M.daemons[name] = {
        opts   = opts,
        job    = job,
        config = config
    }
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
    -- M.daemons[daemon.job.name] = nil
end

function M.killall()
    for name, _ in ipairs(M.daemons) do
        M.stop(name)
    end
end


return M
