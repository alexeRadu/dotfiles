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

function! dbug#StopDebug()
	if !exists('s:job') || job_status(s:job) != 'run'
		return
	endif

	call job_stop(s:job)
endfunction

function! dbug#LoadTarget(fname)
	if !executable(a:fname)
		echo "File " . a:fname . " is not a valid executable"
	endif

	let first_char = strgetchar(a:fname, 0)
	if first_char != '/' && first_char != '.'
		let fname = "./" . a:fname
	else
		let fname = a:fname
	endif

	let fpath = exepath(fname)
	if empty(fpath)
		echo "DBUG: unable to find path to file " . fname
	endif

	let msg = {"name": "load-target", "path": fpath}
	call dbug#SendMessage(msg)
endfunction

function! dbug#ToggleBreakpoint(fname, lineno)
	let msg = {"name": "toggle-breakpoint", "filename": a:fname, "line": a:lineno}

	call dbug#SendMessage(msg)
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

