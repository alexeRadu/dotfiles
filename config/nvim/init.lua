local api = vim.api

local function map(mode, lhs, rhs, opts)
	local options = {noremap = true}

	if opts then
		options = vim.tbl_extend('force', options, opts)
	end

	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Mappings for dbug plugin
map('', '<f5>',    ':Dbg<CR>')
map('', '<f6>',    ':DbgAttach<CR>')
map('', '<f7>',    ':DbgStop<CR>')
map('', '<f9>',    ':DbgContinue<CR>')
map('', '<f10>',   ':DbgNext<CR>')
map('', '<f11>',   ':DbgStep<CR>')
map('', '<f12>',   ':DbgBreakpoint<CR>')

api.nvim_command('set runtimepath ^=~/.vim')
api.nvim_command('set runtimepath +=~/.vim/after')
api.nvim_command('source ~/.vimrc')
api.nvim_command('let g:python_host_prog=\'/usr/bin/python3\'')

api.nvim_set_option("guifont", "IBM Plex Mono Light:h10")
