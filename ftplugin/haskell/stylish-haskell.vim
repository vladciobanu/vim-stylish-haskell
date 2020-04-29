if !exists("g:stylish_haskell_command")
  if executable("stylish-haskell")
    let g:stylish_haskell_command = "stylish-haskell"
  else
    echom "stylish-haskell not found in $PATH"
  endif
endif

if !exists("g:stylish_haskell_options")
  let g:stylish_haskell_options = [ ]
endif

function! __OverwriteBuffer(output)
  let winview = winsaveview()
  if !exists("g:stylish_haskell_dont_override")
    silent! undojoin
    normal! gg"_dG
    call append(0, split(a:output, '\v\n'))
    normal! G"_dd
  else
    edit
  endif
  call winrestview(winview)
endfunction

function! __StylishHaskell()
  if executable(split(g:stylish_haskell_command)[0])
    call __RunStylishHaskell()
  elseif !exists("s:exec_warned")
    let s:exec_warned = 1
    echom "stylish-haskell executable not found"
  endif
endfunction

function! __RunStylishHaskell()
  let output = system(g:stylish_haskell_command . " " . join(g:stylish_haskell_options, ' ') . " " . bufname("%"))
  let errors = matchstr(output, '\(Language\.Haskell\.Stylish\.Parse\.parseModule:[^\x0]*\)')
  if v:shell_error != 0
    echom output
  elseif empty(errors)
    call __OverwriteBuffer(output)
    write
  else
    echom errors
  endif
endfunction

augroup stylish-haskell
  autocmd!
  autocmd BufWritePost *.hs call __StylishHaskell()
augroup END
