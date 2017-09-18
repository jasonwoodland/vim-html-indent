" Vim filetype plugin file
" Language:	HTML
" Maintainer:	Jason Woodland <me@jasonwoodland.com>
" Last Change:	Wed 13 Sep 2017

let b:did_indent = 1

setlocal indentexpr=HtmlIndentGet(v:lnum,0)
setlocal indentkeys=o,O,*<Return>,<>>,<<>,/,{,}

set cpo-=C

if !exists('b:html_indent_open')
    let b:html_indent_open = '.\{-}<\a'
endif

if !exists('b:html_indent_close')
    let b:html_indent_close = '.\{-}</'
endif

if exists('*HtmlIndentGet') | finish | endif

fun! HtmlIndentGet(cur_lnum, use_syntax_check)
    let cur_lnum = a:cur_lnum
    let cur_line = getline(cur_lnum)
    let prev_lnum = prevnonblank(cur_lnum - 1)
    let prev_line = getline(prev_lnum)

    " Zero indent for start of file
    if prev_lnum == 0
        return 0
    endif

    " Get indentation from prev line
    let ind = indent(prev_lnum)

    " Get attribute indentation from prev line
    let align = match(prev_line, '^\s*<[^ >]\+\s\+\zs\w.*[^>]$') - 1

    " If prev_line is >...</tag> then find <tag... indentation
    if match(prev_line, '>.*</[a-zA-Z0-9-]*>$') != -1
	let slnum = prev_lnum

	while match(getline(slnum), '^\s*<') == -1
	    let slnum = slnum - 1
	endwhile

	return indent(slnum)
    endif

    " If prev_line is ...</tag> then keep indentation
    if match(prev_line, '</[a-zA-Z0-9-]*>$') != -1
	return indent(prev_lnum)
    endif

    " If cur_line is </close>
    if match(cur_line, '^\s*</[a-zA-Z]*>$') != -1	

	" If prev_line is ...attr> then search up for <open...
	if match(prev_line, '^\s*[^<]*>$') != -1
	    let slnum = prev_lnum

	    while match(getline(slnum), '^\s*<') == -1
		let slnum = slnum - 1
	    endwhile

	    " If search line was <void... then don't match indentation
	    if XMLMatchVoidElement(slnum) != -1
		return indent(slnum) - &sw
	    endif

	    " Match <open... tag indentation
	    return indent(slnum)

	" If prev_line is a <void>, don't match it's indentation
	elseif XMLMatchVoidElement(prev_lnum) != -1
	    return indent(prev_lnum) - &sw

	" If prev_line is <open>, this line is </close>, so match prev_line's
	" Indentation
	elseif match(prev_line, '^\s*<[^/].*>$') != -1	" If prev_line is <open>
	    return indent(prev_lnum)
	else
	    " Prev_line is not an <open> or a ...attr>
	    return indent(prev_lnum) - &sw		
	endif
    endif

    " If prev_line is <open... then match attr indentation
    if match(prev_line, '^\s*<.*[^>]$') == 0
        return ind + match(prev_line, '\([a-zA-Z0-9]*=.*$\|[a-zA-Z0-9]*$\)') - match(prev_line, '<[a-zA-Z]')
    endif

    " If cur_line is </close> and prev_line is ...attr>, find <open... and
    " Match indentation
    if match(cur_line, '^\s*</.*>$') != -1
		\ && match(prev_line, '^\s*[^<]*>$')
        let slnum = prev_lnum

        while match(getline(slnum), '^\s*<') == -1
            let slnum = slnum - 1
        endwhile

        return indent(slnum) + &sw
    endif
    
    " If prev_line is ...attr>
    if match(prev_line, '^\s*[^<]*>$') == 0
        let slnum = prev_lnum

        while match(getline(slnum), '^\s*<') == -1
            let slnum = slnum - 1
        endwhile

	" If multiline tag was a <void>, don't indent after it
	if XMLMatchVoidElement(slnum) != -1
	    return indent(slnum)
	endif

	" Search is a <open>, indent inside of it
        return indent(slnum) + &sw
    endif

    " If prev_line is <void>, don't indent
    if XMLMatchVoidElement(prev_lnum) != -1
	return indent(prev_lnum)
    endif

    " If prev_line is <open>, indent
    if match(prev_line, '^\s*<[^/].*>$') != -1
	return indent(prev_lnum) + &sw
    endif

    " Otherwise, maintain indentation
    return indent(prev_lnum)
endfun

fun! XMLMatchVoidElement(lnum)
    let line = getline(a:lnum)
    let lnum = a:lnum

    " If line matches void elements list
    if match(line, '<\(!\|area\|base\|basefont\|bgsound\|br\|col\|command\|embed\|frame\|hr\|image\|img\|input\|isindex\|keygen\|link\|menuitem\|meta\|nextid\|param\|source\|track\|wbr\)') != -1
	return 0

    " If line is self-closing <tag />
    elseif match(line, '/>$') != -1
	return 0

    " If line is <open... then find ...arg>
    elseif match(line, '^\s*<.*[^>]$') == 0
	let slnum = lnum

	while match(getline(slnum), '>$') == -1
	    let slnum = slnum + 1
	endwhile

	" If search line is self-closing ...arg />
	return match(getline(slnum), '/>$')
    endif
    
    return -1
endfun
