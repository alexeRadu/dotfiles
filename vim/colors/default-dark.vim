" vim: fdm=marker

set background=dark
" Set the number of colors to match the xterm
set t_Co=256


" {{{ Syntax
" This is in the same order they appear in group-name
" run ':help group-name' to get list of base colors
hi Normal		ctermfg=252	ctermbg=235	cterm=none

hi Comment		ctermfg=240	ctermbg=none	cterm=none

hi Constant		ctermfg=209	ctermbg=none	cterm=none
hi String		ctermfg=36	ctermbg=none	cterm=none
hi Character		ctermfg=36	ctermbg=none	cterm=none
hi Number		ctermfg=209	ctermbg=none	cterm=none
hi Boolean		ctermfg=209	ctermbg=none	cterm=none
hi Float		ctermfg=209	ctermbg=none	cterm=none

hi Identifier		ctermfg=168	ctermbg=none	cterm=bold
hi Function		ctermfg=169	ctermbg=none	cterm=bold

hi Statement		ctermfg=69	ctermbg=none	cterm=none
"hi Conditional		ctermfg=125	ctermbg=none	cterm=none
"hi Repeat		ctermfg=125	ctermbg=none	cterm=none
"hi Label		ctermfg=125	ctermbg=none	cterm=none
"hi Operator		ctermfg=125	ctermbg=none	cterm=none
"hi Keyword		ctermfg=125	ctermbg=none	cterm=none
"hi Exception		ctermfg=125	ctermbg=none	cterm=none

hi PreProc		ctermfg=175	ctermbg=none	cterm=none
hi Include		ctermfg=175	ctermbg=none	cterm=none
hi Define		ctermfg=175	ctermbg=none	cterm=none
hi Macro		ctermfg=175	ctermbg=none	cterm=none
hi PreCondit		ctermfg=175	ctermbg=none	cterm=none


hi Type			ctermfg=209	ctermbg=none	cterm=none
hi StorageClass		ctermfg=209	ctermbg=none	cterm=none
hi Structure		ctermfg=209	ctermbg=none	cterm=none
hi Typedef		ctermfg=209	ctermbg=none	cterm=none

"hi Special		ctermfg=fg	ctermbg=174	cterm=none
"hi SpecialChar		ctermfg=fg	ctermbg=174	cterm=none
hi Tag			ctermfg=fg	ctermbg=174	cterm=none
"hi Delimiter		ctermfg=fg	ctermbg=174	cterm=none
"hi SpecialComment	ctermfg=fg	ctermbg=174	cterm=none
"hi Debug		ctermfg=fg	ctermbg=174	cterm=none

"hi Underlined		ctermfg=228	ctermbg=none	cterm=bold

"hi Ignore		ctermfg=228	ctermbg=none	cterm=bold

hi Error		ctermfg=196	ctermbg=none	cterm=bold

hi Todo			ctermfg=247	ctermbg=none	cterm=bold
" }}}

" {{{ Display
" line numbers and cursors
hi LineNr		ctermfg=244	ctermbg=none	cterm=none
hi CursorLineNr		ctermfg=250	ctermbg=237	cterm=none
hi CursorLine		ctermfg=none	ctermbg=237	cterm=none

" search and visual mode
hi Search		ctermfg=none	ctermbg=none	cterm=reverse
hi Visual		ctermfg=none	ctermbg=237	cterm=none

" statusline
hi StatusLine		ctermfg=White	ctermbg=237	cterm=none
hi StatusLineNC		ctermfg=245	ctermbg=237	cterm=none

" other
hi ColorColumn		ctermbg=237
hi Folded		ctermfg=244	ctermbg=237
" }}}

" {{{ Miscellaneaous
hi ExtraWhitespace	ctermbg=1
" }}}
