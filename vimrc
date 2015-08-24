" ===========================================
" General Setup
" ===========================================

" Print line numbers in front of each line
set number

" Tabs
"retab               " Change the existing tab characters to spaces
"set expandtab       " Insert spaces instead of tab
set tabstop=4       " Change the number of spaces for tab
set shiftwidth=4    " Change the number of space characters inserted for indentation

" Disable all kinds of bells
set noerrorbells

" Title of the window
set title titlestring=%F\ %m

" Remove search highlighting
set nohlsearch

" Remap Esc key to Caps Lock for easy access
inoremap jj <Esc>

" ===========================================
" Color Scheme
" ===========================================

set background=dark

if &term =~ 'xterm'
	" Xterm supports up to 256 colors, so let's use them
	set t_Co=256

	" Freely adapted from the 'ps_color' color_scheme
	hi Normal 	        ctermfg=252		    ctermbg=234		cterm=NONE
	hi Comment	        ctermfg=186		    ctermbg=bg		cterm=NONE
	hi Constant	        ctermfg=210		    ctermbg=bg		cterm=NONE
	hi Cursor	        ctermfg=Black		ctermbg=153		cterm=NONE
	hi CursorColumn     ctermfg=fg		    ctermbg=88		cterm=NONE
	hi CursorLine       ctermfg=Black	    ctermbg=186		cterm=NONE
	hi DiffAdd          ctermfg=fg  	    ctermbg=18		cterm=NONE
else
endif
