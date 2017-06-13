set background=dark

if &term =~ 'xterm'
	" Set the number of colors to match the xterm
	set t_Co=256
	
	" run ':help group-name' to get list of base colors
	
	hi Normal		ctermfg=252	ctermbg=234	cterm=none
	hi Comment		ctermfg=240	ctermbg=none 	cterm=none
	hi Constant		ctermfg=128	ctermbg=none	cterm=none
	hi String		ctermfg=228	ctermbg=none	cterm=none
	hi Character	 	ctermfg=228	ctermbg=none	cterm=none
	hi Number		ctermfg=128	ctermbg=none	cterm=none	
	hi Boolean		ctermfg=128	ctermbg=none	cterm=none
	hi Function		ctermfg=32	ctermbg=none	cterm=bold
	hi Statement		ctermfg=125	ctermbg=none	cterm=none
	hi PreProc		ctermfg=209	ctermbg=none	cterm=none
	hi Type			ctermfg=31	ctermbg=none	cterm=none
	hi Tag			ctermfg=fg	ctermbg=174	cterm=none	
	hi Todo			ctermfg=228	ctermbg=none	cterm=bold

	" line numbers and cursors
	hi LineNr		ctermfg=244	ctermbg=none	cterm=none
	hi CursorLineNr		ctermfg=250	ctermbg=237 	cterm=none
	hi CursorLine		ctermfg=none	ctermbg=237	cterm=none

	" search and visual mode
	hi Search 		ctermfg=none  	ctermbg=none  	cterm=reverse
	hi Visual		ctermfg=none	ctermbg=237 	cterm=none

	" statusline
	hi StatusLine		ctermfg=White	ctermbg=237	cterm=none
	hi StatusLineNC		ctermfg=245	ctermbg=237	cterm=none	

	" other
	hi ColorColumn		ctermbg=237	
	hi Folded		ctermfg=244	ctermbg=237

endif
