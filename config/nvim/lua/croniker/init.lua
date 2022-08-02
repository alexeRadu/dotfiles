local popup = require("plenary.popup")

local M = {}
local buf   = nil
local win   = nil
local timer = vim.loop.new_timer()
local opts = {
    title = "Croniker",
    padding = {2, 5, 2, 5},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
}


function close_window()
    if win then
        vim.api.nvim_win_close(win, true)
        win = nil
        buf = nil
    end

    if timer then
        timer:stop()
        timer = nil
    end
end

function create_window()
    local info = {
        os.date("%A %d/%m/%Y", os.time()),
        "ww" .. os.date("%W", os.time()),
        os.date("%H:%M:%S", os.time()),
    }

    win = popup.create(info, opts)
    buf = vim.api.nvim_win_get_buf(win)

    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":lua require('croniker').toggle_window()<cr>", {silent = true})

    timer = vim.loop.new_timer()

    timer:start(1000, 1, vim.schedule_wrap(function()
        local time     = os.date("%H:%M:%S", os.time())
        local pad_top  = opts.padding[1]
        local pad_left = opts.padding[4]

        if buf then
            vim.api.nvim_buf_set_text(buf, pad_top + 2, pad_left, pad_top + 2, pad_left + #time, {time})
        end
    end))
end

function M.toggle_window()
    if win then
        close_window()
    else
        create_window()
    end
end

return M
