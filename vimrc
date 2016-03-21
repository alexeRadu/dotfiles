" ===========================================
" Commands for easy edits inside vim
" ===========================================

" edit and reload .vimrc 
command! VimRcEdit		:vsp $MYVIMRC
command! VimRcOpen  	:edit $MYVIMRC
command! VimRcReload	:source $MYVIMRC

" ===========================================
" General Setup
" ===========================================

" Print line numbers in front of each line
set number

" Relative numbers
set rnu

" Tabs
set tabstop=4
set shiftwidth=4

" Disable all kinds of bells
set noerrorbells

" Enable the mouse for all modes
set mouse=a

" Search settings
set incsearch

" Turn on the syntax
syntax on

" Highlight current line
set cursorline

" Use colorscheme
colorscheme default-dark

" Ctags
set tags=./tags;/

" ===========================================
" Status line
" ===========================================

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

" ===========================================
" Splits
" ===========================================

" Open split panes to right and bottom
set splitbelow
set splitright

" Navigation
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Resizing
nnoremap - <c-w>-
nnoremap = <c-w>+
nnoremap _ <c-w><
nnoremap + <c-w>>

" ===========================================
" Basic Mappings
" ===========================================

" Save current buffer
nnoremap <c-s> :w<cr>
inoremap <c-s> <esc>:w<cr>
vnoremap <c-s> <esc>:w<cr>

" Save current buffer and exit
nnoremap <c-w> :x<cr>
inoremap <c-w> <esc>:x<cr>
vnoremap <c-w> <esc>:x<cr>

" Exit without saving
nnoremap <c-q> :q!<cr>
inoremap <c-q> <esc>:q!<cr>
vnoremap <c-q> <esc>:q!<cr>

" Insert a space, tab, line in normal mode
nnoremap <space> i<space><esc>l
nnoremap <tab> i<tab><esc>l
nnoremap <c-o> o<esc>k


" =========================================
" Folding
" ===========================================

nnoremap z{ vi{zf

function! FoldEnable()
	set foldmethod=manual
	set foldcolumn=3
endfunc
command! FoldEnable	:call FoldEnable()


" =========================================
" Show highlighting groups for current word
" ===========================================
nnoremap <c-s-p> :call <SID>SynStack()<CR>
function! <SID>SynStack()
	if !exists("*synstack")
		return
	endif
	echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

