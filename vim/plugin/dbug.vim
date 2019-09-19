if exists('g:loaded_dbug')
	finish
endif
let g:loaded_dbug = 1

command! -nargs=0 Dbg				call dbug#StartDebug()
command! -nargs=0 DbgStop		call dbug#StopDebug()
command! -nargs=0 DbgStatus call dbug#CheckStatus()
command! -nargs=1 DbgSend		call dbug#SendMessage(<q-args>)
