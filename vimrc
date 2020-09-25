" Packages {{{1
call plug#begin('~/.vim/plugged')

Plug 'chriskempson/base16-vim'
Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh'}

call plug#end()

syntax on
filetype plugin indent on

" LSP config {{{1
set hidden
let g:LanguageClient_serverCommands = {
	\'cpp': ['clangd'],
	\ }

nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> gr :call LanguageClient_textDocument_references()<CR>

" fff File manager {{{2
let g:fff#split = "30vnew"
let g:fff#split_direction = "nosplitbelow nosplitright"

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

" Turn on the syntax highlighting only when the terminal supports colors.
if &t_Co > 1
	syntax on
endif

" Highlight current line
set cursorline

" Use colorscheme
set background=dark
set t_Co=256
let base16colorspace=256
colorscheme base16-oceanicnext
hi CursorLineNr cterm=none

" Ctags
set tags=./tags;/

" Enable modeline
set modeline

set wildmenu			" enable completion mode
set wildmode=longest,list	" complete longest commont string then list alternatives

set nowrap

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
let g:dbug_file_hint="/home/radu/zephyrproject/zephyr/samples/hello_world/build/zephyr/zephyr.elf"
let g:dbug_file="/home/radu/zephyrproject/zephyr/samples/hello_world/build/zephyr/zephyr.elf"
let g:dbug_gdb_path="/home/radu/zephyr-sdk/arm-zephyr-eabi/bin/arm-zephyr-eabi-gdb"
let g:dbug_remote_hint="localhost:3333"

" Netrw {{{1
nnoremap <silent> \ :Exp<CR>
