if exists('g:loaded_dbug')
	finish
endif
let g:loaded_dbug = 1

sign define dbg_bp	text=●
sign define dbg_pc	text=->

command! -nargs=0 Dbg							call dbug#StartDebug()
command! -nargs=0 DbgStop					call dbug#StopDebug()
command! -nargs=0 DbgStatus				call dbug#CheckStatus()
command! -nargs=1 DbgSend					call dbug#SendMessage(<q-args>)
command! -nargs=0 DbgBreakpoint		call dbug#ToggleBreakpoint(bufname("%"), getcurpos()[1])
command! -nargs=0 DbgContinue			call dbug#Continue()

command! -nargs=1 -complete=file DbgLoad call dbug#LoadTarget(<q-args>)

nnoremap <silent> <f9> :DbgBreakpoint<CR>
nnoremap <silent> <f5> :DbgContinue<CR>
