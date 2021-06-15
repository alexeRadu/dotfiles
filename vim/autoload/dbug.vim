function! dbug#StartDebug(...)
	let server = "/home/radu/.vim/bin/python3/dbug/main.py"

	if !exists("g:dbug_gdb_path")
		let cmd = ['python3', server]
	else
		let cmd = ['python3', server, g:dbug_gdb_path]
	endif

	let s:job = job_start(cmd, {'in_mode': 'json', 'out_mode': 'json'})

	if exists("g:dbug_file")
		call dbug#File()
	endif
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
		:redraw
	endif

	if g:dbug_file !~ "^\\(\\~/\\|/\\|\\./\\)"
		g:dbug_file = "./" . g:dbug_file
	endif

	if !executable(g:dbug_file)
		echo "File '" . g:dbug_file . "' is not a valid executable"
		unlet g:dbug_file
		return
	endif

	let fpath = exepath(g:dbug_file)
	if fpath == ""
		echo "File '" . g:dbug_file . "' is not a valid executable"
		unlet g:dbug_file
		return
	endif

	call ch_sendexpr(s:job, {"name": "file", "path": fpath})
endfunction

function! dbug#Remote()
	if !exists("g:dbug_remote_hint")
		g:dbug_remote_hint = ""
	endif

	let address = input("Remote: ", g:dbug_remote_hint)

	call ch_sendexpr(s:job, {"name": "remote", "address": address})
endfunction

function! dbug#Load()
	call ch_sendexpr(s:job, {"name": "load"})
endfunction

function! dbug#ToggleBreakpoint(fname, lineno)
	call ch_sendexpr(s:job, {"name": "toggle-breakpoint", "filename": a:fname, "line": a:lineno})
endfunction

function! dbug#Run()
	call ch_sendexpr(s:job, {"name": "run"})
endfunction

function! dbug#Continue()
	call ch_sendexpr(s:job, {"name": "continue"})
endfunction

function! dbug#Pause()
	call ch_sendexpr(s:job, {"name": "pause"})
endfunction

function! dbug#Step()
	call ch_sendexpr(s:job, {"name": "step"})
endfunction

function! dbug#RunUntill(fname, lineno)
	call ch_sendexpr(s:job, {"name": "run-untill", "filename": a:fname, "line": a:lineno})
endfunction

function! dbug#CheckStatus()
	if exists('s:job')
		echo "job status: " . job_status(s:job)
	else
		echo "job not started"
	endif
endfunction
