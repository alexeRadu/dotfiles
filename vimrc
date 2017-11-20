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
