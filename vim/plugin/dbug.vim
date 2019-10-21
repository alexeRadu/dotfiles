if exists('g:loaded_dbug')
	finish
endif
let g:loaded_dbug = 1

sign define dbg_bp	text=●
sign define dbg_pc	text=->

command! -nargs=0 Dbg							call dbug#StartDebug()
command! -nargs=0 DbgStop					call dbug#StopDebug()
command! -nargs=0 DbgStatus				call dbug#CheckStatus()

command! -nargs=0 DbgFile					call dbug#File()
command! -nargs=0 DbgRemote				call dbug#Remote()
command! -nargs=0 DbgLoad					call dbug#Load()

command! -nargs=0 DbgBreakpoint		call dbug#ToggleBreakpoint(bufname("%"), getcurpos()[1])
command! -nargs=0 DbgContinue			call dbug#Continue()
command! -nargs=0 DbgStep					call dbug#Step()

nnoremap <silent> <f5>  :DbgContinue<CR>
nnoremap <silent> <f9>  :DbgBreakpoint<CR>
nnoremap <silent> <f10> :DbgStep<CR>
nnoremap <silent> <f8> :call dbug#RunUntill(bufname("%"), getcurpos()[1])<CR>
