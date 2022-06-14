local o = vim.o

o.tabstop     = 2
o.shiftwidth  = 2
o.softtabstop = 2
o.expandtab   = true

bind_key('n', '<leader><cr>', ':luafile %<cr>')
