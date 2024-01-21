" vim-searchalot - Searchin in files, and highlighting the result
" Maintainer:    Leon Schreuder
" Version:       0.1

if exists("g:loaded_searchalot") && !exists('g:force_reload_ftplug_vim_UT')
  finish
endif
let g:loaded_searchalot = 1

command! -nargs=? Searcha call Searcha('<args>')
command! -nargs=? SearchaFile call SearchaFile('<args>')

" Searcha
" Searcha?
" Like :grep, but  uses fastet available searcher and then simply searches the entire CWD

" search for a specific word as a command
fu! Searcha(...)
  call SearchWord(a:1, 0, 0, '*')
endfu

fu! SearchaFile(filePath, ...)
  call SearchWord(a:1, 0, 0, a:filePath)
endfu

fu! SearchaCurrentFile(...)
  call SearchWord(a:1, 0, 0, expand('%:.'))
endfu

fu! SearchaCurrentWord()
  call SearchWord(expand("<cword>"), 1, 1, "*")
endfu

fu! SearchaSelectedWord()
  call SearchWord(Get_visual_selection(), 0, 1, "*")
endfu


fu! SearchWord(searchString, isFullWord, shouldEscape, location)
  " so we don't ediit the grepprg in case someone was using it, the current
  " values are saved and restored
  let oldgrepprg = &grepprg
  let orig_grepformat = &grepformat


  if exepath("rg") != ""
    if a:isFullWord == 1
      let &grepprg = "rg --vimgrep --word-regexp"
    else
      let &grepprg = "rg --vimgrep"
    endif


    if a:shouldEscape == 1
      let escapedSearchString = EscapeForGNURegexp(a:searchString)
      let searchCmd = "grep! '" . escapedSearchString . "' " . a:location
    else
      let searchCmd = "grep! '" . a:searchString . "' " . a:location
    endif

  else
    let &grepprg='internal'
    let escapedSearchString = EscapeForVimRegexp(a:searchString)
    if a:isFullWord == 1
      let searchCmd = "grep! /\\<" . escapedSearchString . "\\>/j " . a:location
    else
      let searchCmd = "grep! /" . escapedSearchString . "/j " . a:location
    endif
  endif

  echomsg "searching:'" . searchCmd . "' using '" . &grepprg . "'"
  execute 'silent ' . searchCmd
  copen " open the results in the quickfix window

  let &grepprg = oldgrepprg
  let &grepformat = orig_grepformat
endfu

" credit: https://stackoverflow.com/a/61517520/3968618
function! EscapeForVimRegexp(str)
  return escape(a:str, '^$.*?/\[]')
endfunction
function! EscapeForGNURegexp(str)
  return escape(a:str, '^$.*?/\[]()' . '"' . "'")
endfunction

" credit: https://stackoverflow.com/a/6271254/3968618
function! Get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction


" }}}

