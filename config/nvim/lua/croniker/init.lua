local popup = require("plenary.popup")

local M = {}
local buf = nil
local win = nil
local timer = vim.loop.new_timer()
local opts = {
    title = "Croniker",
    padding = {2, 5, 2, 5},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
}


function M.close_window()
    if win then
        vim.api.nvim_win_close(win, true)
    end

    timer:stop()
end

function M.create_window()
    -- Always create a new window
    -- this will lead to a performance penalty that is acceptable but the
    -- code will be simples
 
    if win then
        win = nil
    end

    -- Get the time info to be displayed
    local info = {
        os.date("%A %d/%m/%Y", os.time()),
        "ww" .. os.date("%W", os.time()),
        os.date("%H:%M:%S", os.time()),
    }

    win = popup.create(info, opts)
    buf = vim.api.nvim_win_get_buf(win)

    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":lua require('croniker').close_window()<cr>", {silent = true})

    timer:start(1000, 1, vim.schedule_wrap(function()
        local time     = os.date("%H:%M:%S", os.time())
        local pad_top  = opts.padding[1]
        local pad_left = opts.padding[4]

        vim.api.nvim_buf_set_text(buf, pad_top + 2, pad_left, pad_top + 2, pad_left + #time, {time})
    end))
end

return M
