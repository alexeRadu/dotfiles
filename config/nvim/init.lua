local api = vim.api

api.nvim_command('set runtimepath ^=~/.vim')
api.nvim_command('set runtimepath +=~/.vim/after')
api.nvim_command('source ~/.vimrc')
api.nvim_command('let g:python_host_prog=\'/usr/bin/python3\'')

api.nvim_set_option("guifont", "IBM Plex Mono Light:h10")
