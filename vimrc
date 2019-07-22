" Packages {{{1
" Install packages using pathogen
execute pathogen#infect()
syntax on
filetype plugin indent on

" fff File manager {{{2
let g:fff#split = "30vnew"
let g:fff#split_direction = "nosplitbelow nosplitright"

" Basic settings {{{1
" Leader key; not sure yet if it is usefull but I'm willing to give it a try
let mapleader = "\<space>"

" TODO: listchars use
" set list

" Print line numbers in front of each line
set number

" Relative numbers (rnu)
if exists("&rnu")
	" For version <= 7.0.xxx rnu is not implemented
	set rnu
endif

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

function SetColorColumn(value)
	if exists('+colorcolumn')
		let &l:colorcolumn=join(range(a:value, 256), ',')
	endif
endfunction

" By default the 'colorcolumn' should be set at 80
autocmd FileType c,h,cpp :call SetColorColumn(80)
autocmd FileType vim :call SetColorColumn(80)
autocmd Filetype markdown :call SetColorColumn(80)

" For certain filetypes on different projects the colorcolumn should be set to
" a different value than the default

" TODO: detect we are in a zephyr project
" set 'colorcolumn' only for 'gitcommit' file type for the Zephyr project
autocmd FileType gitcommit :call SetColorColumn(72)

" Highlight current line
set cursorline

" Use colorscheme
colorscheme default-dark

" Ctags
set tags=./tags;/

" Enable modeline
set modeline

set wildmenu			" enable completion mode
set wildmode=longest,list	" complete longest commont string then list alternatives

" {{{1 Whitespaces

" Highlight extra whitespaces and remove them.
" references:
"   http://vim.wikia.com/wiki/Highlight_unwanted_spaces
"   http://vim.wikia.com/wiki/Remove_unwanted_spaces
augroup whitespaces
	autocmd!
	" Detect any space withing a tab sequence and any trailing whitespace on
	" buffer entrance and insert leave.
	autocmd BufWinEnter * match ExtraWhitespace /\t*\zs \+\ze\t\+\|\s\+$/
	autocmd InsertLeave * match ExtraWhitespace /\t*\zs \+\ze\t\+\|\s\+$/

	" When in insert mode don't highlight the current trailing whitespace.
	autocmd InsertEnter * match ExtraWhitespace  /\s\+\%#\@<!$/

	" When writing buffer clear all extra whitespaces
	autocmd BufWritePre * %s/\t*\zs \+\ze\t\+//ge
	autocmd BufWritePre * %s/\s\+$//ge

	" remove matches when leaving buffer (due to some glitch)
	if version >= 702
		autocmd BufWinLeave * call clearmatches()
	endif
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
