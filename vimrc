" ===========================================
" Command for easy edits inside vim
" ===========================================

" edit .vimrc by entering the command :EditVim
function! EditVim()
	:vsplit $MYVIMRC
endfunction

if !exists(":EditVim")
	command EditVim :call EditVim()
endif

" automatically reload .vimrc when closed
function! ReloadVimRC()
	:source $MYVIMRC
endfunction

if !exists("g:vimrcLoaded")
	autocmd BufUnload .vimrc :call ReloadVimRC()
	let	g:vimrcLoaded = 1
endif

" ===========================================
" General Setup
" ===========================================

" Print line numbers in front of each line
set number

" Relative numbers
set rnu

" Tabs
set tabstop=4       " Change the number of spaces for tab
set shiftwidth=4    " Change the number of space characters inserted for indentation

" Disable all kinds of bells
set noerrorbells

" Title of the window
set title titlestring=%F\ %m

" Remove search highlighting
"set nohlsearch

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

"Ctags
set tags=./tags;/

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
nnoremap <c-x> :x<cr>
inoremap <c-x> <esc>:x<cr>
vnoremap <c-x> <esc>:x<cr>

" Exit without saving
nnoremap <c-q> :q!<cr>
inoremap <c-q> <esc>:q!<cr>
vnoremap <c-q> <esc>:q!<cr>

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

