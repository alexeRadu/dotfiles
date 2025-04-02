local o   = vim.o
local api = vim.api


local path = api.nvim_buf_get_name(0)
local stdpath = api.nvim_eval('stdpath("data")')


if string.match(path, stdpath) then
    -- this means we are accesing one of the lua files that is inside the
    -- neovim DATA path; usually here the plugin authors have opted to use
    -- 2 spaces for a tab rather then 4
    o.tabstop     = 2
    o.shiftwidth  = 2
    o.softtabstop = 2
else
    o.tabstop     = 4
    o.shiftwidth  = 4
    o.softtabstop = 4
end

o.expandtab = true


api.nvim_set_keymap('n', '<leader><cr>', ':luafile %<cr>', {noremap = true, silent = true})
