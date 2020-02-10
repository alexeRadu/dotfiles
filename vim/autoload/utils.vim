function! utils#SetColorColumn(value)
	if exists('+colorcolumn')
		let &l:colorcolumn=join(range(a:value, 256), ',')
	endif
endfunction
