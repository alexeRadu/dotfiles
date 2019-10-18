if exists('g:loaded_dbug')
	finish
endif
let g:loaded_dbug = 1

sign define dbg_bp	text=●
sign define dbg_pc	text=->

function! DbgStartCompletion(arg_lead, cmd_line, cursor_pos)
	"  when no other value is given autocomplete with the default
	"  this was introduced for convenience
	if a:arg_lead == ""
		return ["/home/radu/zephyr-sdk/arm-zephyr-eabi/bin/arm-zephyr-eabi-gdb"]
	endif

	" TODO: improvements:
	" - autocomplete when a path is provided
	" - remember a list of previously used debuggers
	return []
endfunction

function! DbgRemoteCompletion(arg_lead, cmd_line, cursor_pos)
	if a:arg_lead == ""
		return ["load"]
	endif

	return []
endfunction

command! -nargs=0 DbgStop					call dbug#StopDebug()
command! -nargs=0 DbgStatus				call dbug#CheckStatus()
command! -nargs=1 DbgSend					call dbug#SendMessage(<q-args>)
command! -nargs=0 DbgBreakpoint		call dbug#ToggleBreakpoint(bufname("%"), getcurpos()[1])
command! -nargs=0 DbgContinue			call dbug#Continue()

command! -nargs=? -complete=customlist,DbgStartCompletion Dbg
					\ call dbug#StartDebug(<q-args>)
command! -nargs=? -complete=customlist,DbgRemoteCompletion DbgRemote
					\ call dbug#Remote(<q-args>)
command! -nargs=1 -complete=file DbgLoad call dbug#LoadTarget(<q-args>)

nnoremap <silent> <f9> :DbgBreakpoint<CR>
nnoremap <silent> <f5> :DbgContinue<CR>
