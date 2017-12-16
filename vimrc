" Packages {{{1
" Install packages using pathogen
execute pathogen#infect()
syntax on
filetype plugin indent on

" Basic settings {{{1
" Leader key; not sure yet if it is usefull but I'm willing to give it a try
let mapleader = ","

" Print line numbers in front of each line
set number

" Relative numbers (rnu)
if exists("&rnu")
	" For version <= 7.0.xxx rnu is not implemented
	set rnu
endif

" Tabs
set tabstop=8
set shiftwidth=8

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

if exists('+colorcolumn')
	set colorcolumn=80
endif

" Highlight current line
set cursorline

" Use colorscheme
colorscheme default-dark

" Ctags
set tags=./tags;/

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
nnoremap z{ vi{zf

function! FoldEnable()
	set foldmethod=syntax
	set foldcolumn=3
endfunc
command! FoldEnable	:call FoldEnable()

" save folds on buffer leave and load when enter
autocmd BufWinLeave * mkview
autocmd BufWinEnter * silent loadview

" A way to toggle comments for lines or selected chunks of code
let s:comment_map = {
	\	"c":		["/* ",	"*/"],
	\	"python":	["# ",	""],
	\	"vim":		["\" ",	""],
	\}

function! ToggleComment()
	if has_key(s:comment_map, &filetype)
		let [s, e] = s:comment_map[&filetype]
		echo "start " s "end" e
	else
		echo "No comment found for filetype...better add one!"
	end
endfunction

" Arduino Specific {{{1
let g:arduino_dir = '/home/radu/arduino'
let g:arduino_cmd = '/home/radu/arduino/arduino'
let g:arduino_serial_cmd = 'picocom /dev/ttyACM0 -b 9600 -l'

augroup filetype_arduino
	autocmd!
	autocmd FileType arduino nnoremap <buffer> <leader>c :ArduinoVerify<CR>
	autocmd FileType arduino nnoremap <buffer> <leader>s :ArduinoSerial<CR>
	autocmd FileType arduino nnoremap <buffer> <leader>u :ArduinoUpload<CR>
	autocmd FileType arduino nnoremap <buffer> <leader>d :ArduinoUploadAndSerial<CR>
augroup END
