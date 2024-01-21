" vim-searchalot - Searchin in files, and highlighting the result
" Maintainer:    Leon Schreuder
" Version:       0.1

" if exists("g:loaded_searchalot") && !exists('g:force_reload_ftplug_vim_UT')
"   finish
" endif
" let g:loaded_searchalot = 1

command! -nargs=+ Searcha call Searcha('<args>')
command! -nargs=+ SearchaFile call SearchaFile('<args>')

" Searcha
" Searcha?
" Like :grep, but  uses fastet available searcher and then simply searches the entire CWD

" search for a specific word as a command
fu! Searcha(...)
  call SearchWord('*', 0, a:000)
endfu

fu! SearchaFile(filePath, ...)
  call SearchWord(a:filePath, 0, a:000)
endfu

fu! SearchaCurrentFile(...)
  call SearchWord(expand('%:.'), 0, a:000)
endfu

fu! SearchaCurrentWord()
  call SearchWord("*", 1, [EscapeForGNURegexp(expand("<cword>"))])
endfu

fu! SearchaSelectedWord()
  call SearchWord("*", 0, [EscapeForGNURegexp(s:get_visual_selection())])
endfu

" fu! searcha#regex(location, searchesList)
" endfu

fu! SearchWord(location, isFullWord, searchesList)
  " so we don't ediit the grepprg in case someone was using it, the current
  " values are saved and restored
  let oldgrepprg = &grepprg
  let orig_grepformat = &grepformat

  if exepath("rg") != ""
    let &grepprg = "rg --vimgrep"
  else
    let &grepprg='internal'
  endif

  let searches = searchalot#performOptionalEscaping(a:searchesList)
  if a:isFullWord == 1
    let searches = searchalot#addWordBoundries(searches)
  endif

  let grepCmd = searchalot#buildGrepCommand(searches, a:location)

  echomsg "searching:'" . grepCmd . "' using '" . &grepprg . "'"
  execute 'silent ' . grepCmd
  copen " open the results in the quickfix window

  let &grepprg = oldgrepprg
  let &grepformat = orig_grepformat

  for curSearch in a:searchesList
    exec ":Mark /" . EscapeForVimRegexp(curSearch) . "/"
  endfor
endfu

fu! searchalot#buildGrepCommand(searchesList, location)
  let grepCmd = ['grep!']

  if &grepprg == 'internal'
    for curSearch in a:searchesList
      call add(grepCmd, "/" . curSearch . "/j")
    endfor
  else
    for curSearch in a:searchesList
      call add(grepCmd, "-e '" . curSearch . "'")
    endfor
  endif

  call add(grepCmd, a:location)
  return join(grepCmd, ' ')
endfu

fu! searchalot#performOptionalEscaping(searchesList)
  let processedSearches = []
  if &grepprg == 'internal'
    for curSearch in a:searchesList
      call add(processedSearches, EscapeForVimRegexp(curSearch))
    endfor
  else
    let processedSearches = a:searchesList
  endif
  return processedSearches
endfu

fu! searchalot#addWordBoundries(searchesList)
  let processedSearches = []
  for curSearch in a:searchesList
    if &grepprg == 'internal'
      call add(processedSearches, "\\<" . curSearch . "\\>")
    else
      call add(processedSearches, "\\b" . curSearch . "\\b")
    endif
  endfor
  return processedSearches
endfu

" credit: https://stackoverflow.com/a/61517520/3968618
function! EscapeForVimRegexp(str)
  return escape(a:str, '^$.*?/\[]')
endfunction
function! EscapeForGNURegexp(str)
  return escape(a:str, '^$.*?/\[]()' . '"' . "'")
endfunction

" credit: https://stackoverflow.com/a/6271254/3968618
function! s:get_visual_selection()
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

