" Packages {{{1
call plug#begin('~/.vim/plugged')

Plug 'joshdick/onedark.vim'
Plug 'tpope/vim-surround'
Plug 'dhruvasagar/vim-table-mode'
Plug 'PProvost/vim-ps1'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'lervag/vimtex'
Plug 'sirver/ultisnips'
Plug 'honza/vim-snippets'

call plug#end()

syntax on
filetype plugin indent on

" FZF keymaps
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>

" Basic settings {{{1

" Leader key; not sure yet if it is usefull but I'm willing to give it a try
let mapleader = "\<space>"

" Listchars to show better tabs/spaces demarcation
set list
set listchars=tab:\|\ 
"set listchars+=space:·

" Enable numbers and relative number (rnu)
set number
if exists("&rnu") | set rnu | endif

" Disable all kinds of bells
set noerrorbells

" Enable the mouse for all modes
set mouse=a

" Search settings
set incsearch
set hlsearch

" Search keynding: search all occurences of the word under cursor and type the
" number of occurences in the statusline
" For more info see: https://vim.fandom.com/wiki/Count_number_of_matches_of_a_pattern
nnoremap ,* *<C-o>:%s///gn<CR><C-o>

" Turn on the syntax highlighting only when the terminal supports colors.
if &t_Co > 1
	syntax on
endif

" Highlight current line
set cursorline

" Use colorscheme
set background=dark
colorscheme onedark
hi CursorLineNr cterm=none

" Ctags
set tags=./tags;/

" Enable modeline
set modeline

set wildmenu			" enable completion mode
set wildmode=longest,list	" complete longest commont string then list alternatives

set nowrap
set noswapfile

" {{{1 Find functions in C Files
nnoremap <leader>f :vimgrep /^\(\(phyStatus_t\\|static\\|void\\|int8_t\\|otError\\|otRadioState\\|otRadioCaps\\|bool\)\s\+\)\+\(\w\)\+(/ %<CR>
nnoremap <leader>n :cn<CR>
nnoremap <leader>p :cp<CR>

" {{{1 Whitespaces

" Highlight extra whitespaces and remove them.
" references:
"   http://vim.wikia.com/wiki/Highlight_unwanted_spaces
"   http://vim.wikia.com/wiki/Remove_unwanted_spaces

hi ExtraWhitespace	ctermbg=1

augroup whitespaces
	autocmd!
	" Detect any space withing a tab sequence and any trailing whitespace on
	" buffer entrance and insert leave.
	autocmd BufWinEnter * match ExtraWhitespace /\t*\zs \+\ze\t\+\|\s\+$/
	autocmd InsertLeave * match ExtraWhitespace /\t*\zs \+\ze\t\+\|\s\+$/

	" When in insert mode don't highlight the current trailing whitespace.
	autocmd InsertEnter * match ExtraWhitespace  /\s\+\%#\@<!$/

	" When writing buffer clear all extra whitespaces
	" autocmd BufWritePre * %s/\t*\zs \+\ze\t\+//ge
	" autocmd BufWritePre * %s/\s\+$//ge

	" remove matches when leaving buffer (due to some glitch)
	if version >= 702
		autocmd BufWinLeave * call clearmatches()
	endif

	" command to clear all whitespaces from the current document
	command! -nargs=0 ClearWhitespaces :%s/\t*\zs \+\ze\t\+\|\s\+$/

augroup END
" }}}
" Status Line {{{1
" make status line always visible
set laststatus=2

" show the current editing status
set showmode

" human readable file size
fu! StatuslineFilesize()
	let filesize = line2byte(line("$") + 1) - 1

	if $filetype == "netrw" || filesize < 0
		return ""
	elseif filesize < 1024
		return " | " . filesize . " bytes"
	elseif filesize < 1024*1024
		return " | " . (filesize / 1024) . " kB"
	else
		return " | " . (filesize / (1024*1024)) . " MB"
	endif
endf

" format statusline
set statusline=%t\ \|\ %L\ lines%{StatuslineFilesize()}\ %y%m%=L%-6l\ C%-2c

" Prefer new splits to the right and bottom
set splitbelow
set splitright

" Folding {{{1
" save folds on buffer leave and load when enter
" TODO: cool feature but should be enabled more carefull so to not overwrite
" new settings added to .vimrc (ex: colorcolumn)
" autocmd BufWinLeave *.c  mkview
" autocmd BufWinEnter *.c silent loadview

" custom folding
augroup custom_folding
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker
augroup END

" Command-T {{{1
let g:CommandTWildIgnore=",*.obj"

" Debugging {{{1
function! DbugWatchExpression(type)
	if a:type ==# 'v'
		execute "normal! `<v`>y"
	else
		return
	endif

	silent execute "DbgWatchExpression " .  @@
endfunction

vnoremap <leader>w :<c-u>call DbugWatchExpression(visualmode())<cr>

"let g:dbug_file_hint="/mnt/c/nxp/ot-nxp/build_k32w1/openthread/examples/apps/cli/ot-cli-ftd"
let g:dbug_file="./fact"
"let g:dbug_gdb_path="/usr/local/bin/arm-none-eabi-gdb"
"let g:dbug_remote_hint="localhost:2331"
"let g:dbug_load_on_start=1

" Netrw {{{1
nnoremap <silent> \ :Exp<CR>

" Opening in browser {{{1
" When set open the file but keep the focus for the editor
let g:open_in_browser_keep_focus=1

" The browser used to open the file. Leave empty to use the default browser.
" For Linux: google-chrome, firefox
" For Windows: chrome, firefox
let g:open_in_browser_used_browser=""

if has('win32')
elseif has('unix')
	nnoremap <F2>  :execute "silent !~/.vim/bin/open-in-browser.sh %:p " . g:open_in_browser_keep_focus . " " . g:open_in_browser_used_browser<CR>:redraw!<CR>
endif

" Latex {{{1
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

command! Compile exe ":silent !pdflatex -interaction=nonstopmode " . expand("%:p")
augroup latex_autocmds
	autocmd!
	autocmd BufWritePost *.tex :Compile
augroup END

" Ultisnips {{{1
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
