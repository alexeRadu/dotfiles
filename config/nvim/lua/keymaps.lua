vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<leader>i', ':edit $MYVIMRC<CR>', { silent = true })
vim.keymap.set('n', '<leader>e', ':luafile %<CR>', { silent = true })
vim.keymap.set('n', '<leader>h', ':help ', { silent = false })
vim.keymap.set('n', '<C-s>', ':w<CR>', { silent = false })

-- Keybindings for navigating/creating windows
vim.keymap.set('n', '<C-h>', '<C-w>h', { silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { silent = true })
vim.keymap.set('n', '<C-w>h', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-w>l', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-w>j', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-w>k', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-w>h', ':leftabove vsplit<CR>', { silent = true })
vim.keymap.set('n', '<C-w>l', ':rightbelow vsplit<CR>', { silent = true })
vim.keymap.set('n', '<C-w>j', ':rightbelow split<CR>', { silent = true })
vim.keymap.set('n', '<C-w>k', ':leftabove split<CR>', { silent = true })

-- Moving in insert mode
vim.keymap.set('i', '<C-h>', '<C-c>', { silent = true })
vim.keymap.set('i', '<C-j>', '<C-c>lj', { silent = true })
-- vim.keymap.set('i', '<C-k>', '<C-c>lk', { silent = true })
vim.keymap.set('i', '<C-l>', '<C-c>ll', { silent = true })

-- Terminal keybindings
vim.keymap.set('t', '<C-z>', [[<C-\><C-n>]], { silent = true })
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { silent = true})
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { silent = true})
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { silent = true})
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { silent = true})
