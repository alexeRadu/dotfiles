local api = vim.api

local function map(mode, lhs, rhs, opts)
	local options = {noremap = true}

	if opts then
		options = vim.tbl_extend('force', options, opts)
	end

	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Mappings for dbug plugin
map('', '<f5>',  ':Dbg<CR>')
map('', '<f6>',  ':DbgStop<CR>')
map('', '<f8>',  ':DbgBreakpoint<CR>')
map('', '<f9>',  ':DbgRun<CR>')
map('', '<f10>', ':DbgNext<CR>')
map('', '<f11>', ':DbgStep<CR>')

api.nvim_command('set runtimepath ^=~/.vim')
api.nvim_command('set runtimepath +=~/.vim/after')
api.nvim_command('source ~/.vimrc')
api.nvim_command('let g:python_host_prog=\'/usr/bin/python3\'')

api.nvim_set_option("guifont", "IBM Plex Mono Light:h10")
