if exists('g:autoloaded_dbug')
	finish
endif
let g:autoloaded_dbug = 1

let s:server = "/home/radu/.vim/bin/python3/dbug/main.py"

function! dbug#StartServer()
	let cmd = ['python3', s:server]
	let options = {'in_mode':  'json', 'out_mode': 'json'}

	let s:job = job_start(cmd, options)
endfunction

function! dbug#StartDebug()
	call dbug#StartServer()
endfunction

function! dbug#CheckStatus()
	if exists('s:job')
		echo "job status: " . job_status(s:job)
	else
		echo "job not started"
	endif
endfunction

function! dbug#SendMessage(msg)
	call ch_sendexpr(s:job, a:msg)
endfunction

