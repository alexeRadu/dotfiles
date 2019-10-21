if exists('g:autoloaded_dbug')
	finish
endif
let g:autoloaded_dbug = 1

let s:server = "/home/radu/.vim/bin/python3/dbug/main.py"

function! dbug#StartDebug(...)
	let cmd = ['python3', s:server]

	if !exists("g:dbug_gdb_path")
		let cmd = ['python3', s:server]
	else
		let cmd = ['python3', s:server, g:dbug_gdb_path]
	endif

	let options = {'in_mode':  'json', 'out_mode': 'json'}

	let s:job = job_start(cmd, options)
endfunction

function! dbug#StopDebug()
	if !exists('s:job') || job_status(s:job) != 'run'
		return
	endif

	call job_stop(s:job)
endfunction

function! dbug#File()
	if !exists("g:dbug_file")
		if !exists("g:dbug_file_hint")
			let g:dbug_file_hint = ""
		endif

		let g:dbug_file = input("Executable: ", g:dbug_file_hint, "file")
	endif

	if !executable(g:dbug_file)
		echo "File " . g:dbug_file . " is not a valid executable"
	endif

	let fpath = exepath(g:dbug_file)

	let msg = {"name": "file", "path": fpath}
	call dbug#SendMessage(msg)
endfunction

function! dbug#Remote(...)
	if a:1 == "load"
		let msg = {"name": "target-load"}
		call dbug#SendMessage(msg)
	else
		let remote = input("Remote: ", "localhost")
		let port = input("Port: ", "3333")

		let msg = {"name": "target-remote", "remote": remote, "port": port}
		call dbug#SendMessage(msg)
	endif
endfunction

function! dbug#ToggleBreakpoint(fname, lineno)
	let msg = {"name": "toggle-breakpoint", "filename": a:fname, "line": a:lineno}

	call dbug#SendMessage(msg)
endfunction

function! dbug#Continue()
	let msg = {"name": "continue"}
	call dbug#SendMessage(msg)
endfunction

function! dbug#Step()
	let msg = {"name": "step"}
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

