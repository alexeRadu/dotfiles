if exists('g:loaded_dbug')
	finish
endif
let g:loaded_dbug = 1

sign define dbg_bp	text=●
sign define dbg_pc	text=->

function! DbgRemoteCompletion(arg_lead, cmd_line, cursor_pos)
	if a:arg_lead == ""
		return ["load"]
	endif

	return []
endfunction

command! -nargs=0 Dbg							call dbug#StartDebug()
command! -nargs=0 DbgStop					call dbug#StopDebug()
command! -nargs=0 DbgStatus				call dbug#CheckStatus()
command! -nargs=0 DbgBreakpoint		call dbug#ToggleBreakpoint(bufname("%"), getcurpos()[1])
command! -nargs=0 DbgContinue			call dbug#Continue()
command! -nargs=0 DbgStep					call dbug#Step()
command! -nargs=0 DbgFile					call dbug#File()

command! -nargs=? -complete=customlist,DbgRemoteCompletion DbgRemote
					\ call dbug#Remote(<q-args>)

nnoremap <silent> <f5>  :DbgContinue<CR>
nnoremap <silent> <f9>  :DbgBreakpoint<CR>
nnoremap <silent> <f10> :DbgStep<CR>
