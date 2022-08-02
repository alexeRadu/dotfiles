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
    local date = os.date("%A %d/%m/%Y", os.time())
    local ww   = "ww" .. os.date("%W", os.time())
    local time = os.date("%H:%M:%S", os.time())

    local field_len = math.max(#date, #ww, #time)

    local date_space = (field_len - #date) / 2
    local ww_space   = (field_len - #ww) / 2
    local time_space = (field_len - #time) / 2

    local info = {
        string.format('%' .. tostring(date_space) .. 's', ' ') .. date .. string.format('%' .. tostring(date_space) .. 's', ' '),
        string.format('%' .. tostring(ww_space) .. 's', ' ')   .. ww   .. string.format('%' .. tostring(ww_space) .. 's', ' '),
        string.format('%' .. tostring(time_space) .. 's', ' ') .. time .. string.format('%' .. tostring(time_space) .. 's', ' ')
    }

    win = popup.create(info, opts)
    buf = vim.api.nvim_win_get_buf(win)

    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":lua require('croniker').toggle_window()<cr>", {silent = true})

    timer = vim.loop.new_timer()

    timer:start(1000, 1, vim.schedule_wrap(function()
        local time     = os.date("%H:%M:%S", os.time())
        local pad_top  = opts.padding[1]
        local pad_left = opts.padding[4]

        local time_space = (field_len - #time) / 2

        if buf then
            vim.api.nvim_buf_set_text(buf, pad_top + 2, pad_left + time_space, pad_top + 2, pad_left + time_space + #time, {time})
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
