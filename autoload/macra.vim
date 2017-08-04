let s:interests = []
let s:mappings = []
let s:bufnr = 0
let s:regchar = '@'


function! macra#register(name, ...) abort
  let modes = a:0 ? a:1 : 'nxo'
  call add(s:interests, [a:name, modes])
endfunction

function! macra#start() abort
  let char = nr2char(getchar())
  if empty(char)
    return
  endif
  let s:regchar = char
  call s:store()
  nmap q <Plug>(macra-stop)
  execute printf('normal! q%s', char)
endfunction

function! macra#stop() abort
  normal! q
  call setreg(
        \ s:regchar,
        \ substitute(getreg(s:regchar), 'q$', '', ''),
        \)
  call s:restore()
  nmap q <Plug>(macra-start)
endfunction

function! macra#run() abort
  let char = nr2char(getchar())
  if empty(char)
    return
  endif
  call s:store()
  try
    execute printf('normal! @%s', char)
  catch
    echohl ErrorMsg
    echo substitute(v:exception, '^Vim(.\+):', '', '')
    echohl None
  finally
    call s:restore()
  endtry
endfunction

function! macra#run_over() abort range
  let char = nr2char(getchar())
  if empty(char)
    return
  endif
  call s:store()
  try
    execute printf(
          \ ':%d,%dnormal! @%s',
          \ a:firstline,
          \ a:lastline,
          \ char
          \)
  catch
    echohl ErrorMsg
    echo substitute(v:exception, '^Vim(.\+):', '', '')
    echohl None
  finally
    call s:restore()
  endtry
endfunction


function! s:store() abort
  let s:bufnr = bufnr('%')
  let s:mappings = []
  for [name, modes] in s:interests
    for mode in split(modes, '\zs')
      if empty(maparg(name, mode))
        continue
      endif
      call add(s:mappings, maparg(name, mode, 0, 1))
      execute printf('%sunmap %s', mode, name)
    endfor
  endfor
endfunction

function! s:restore() abort
  let bufnr = bufnr('%')
  execute printf('keepjumps keepalt %dbuffer', s:bufnr)
  for mapping in s:mappings
    call s:map(mapping)
  endfor
  execute printf('keepjumps keepalt %dbuffer', bufnr)
endfunction

function! s:map(mapping) abort
  let options = [
        \ a:mapping.silent ? '<silent>' : '',
        \ a:mapping.expr ? '<expr>' : '',
        \ a:mapping.buffer ? '<buffer>' : '',
        \ a:mapping.nowait ? '<nowait>' : '',
        \]
  execute printf(
        \ '%s%s%s %s %s %s',
        \ a:mapping.mode ==# '!' ? '' : a:mapping.mode,
        \ a:mapping.noremap ? 'noremap' : 'map',
        \ a:mapping.mode ==# '!' ? '!' : '',
        \ join(options),
        \ a:mapping.lhs,
        \ a:mapping.rhs,
        \)
endfunction
