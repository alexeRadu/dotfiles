local o = vim.o

o.tabstop     = 4
o.shiftwidth  = 4
o.softtabstop = 4
o.expandtab   = true

bind_key('n', '<leader><cr>', ':luafile %<cr>')
