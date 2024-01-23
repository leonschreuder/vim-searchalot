" vim-searchalot - Searchin in files, and highlighting the result
" Maintainer:    Leon Schreuder
" Version:       0.1

" if exists("g:loaded_searchalot") && !exists('g:force_reload_ftplug_vim_UT')
"   finish
" endif
" let g:loaded_searchalot = 1


" Searcha
" Searcha?
" Like :grep, but  uses fastet available searcher and then simply searches the entire CWD

" search for a specific word as a command
command! -nargs=+ Searcha call Searcha('<args>')
fu! Searcha(...)
  call SearchWord('*', 0, utl#argparse#SplitArgs(a:1))
endfu

command! -nargs=+ SearchaFile call SearchaFile('<args>')
fu! SearchaFile(filePath, ...)
  call SearchWord(a:filePath, 0, utl#argparse#SplitArgs(a:1))
endfu

command! -nargs=+ SearchaCurrentFile call SearchaCurrentFile('<args>')
fu! SearchaCurrentFile(...)
  call SearchWord(expand('%:.'), 0, utl#argparse#SplitArgs(a:1))
endfu

fu! SearchaCurrentWord()
  call SearchWord("*", 1, [[EscapeForGNURegexp(expand("<cword>"))]])
endfu

fu! SearchaSelectedWord()
  call SearchWord("*", 0, [[EscapeForGNURegexp(s:get_visual_selection())]])
endfu

fu! SearchWord(location, isFullWord, searchesList)
  " so we don't ediit the grepprg in case someone was using it, the current
  " values are saved and restored
  let oldgrepprg = &grepprg
  let orig_grepformat = &grepformat

  if exepath("rg") != ""
    let &grepprg = "rg --vimgrep --pcre2"
  else
    let &grepprg='internal'
  endif

  " let searches = searchalot#performOptionalEscaping(a:searchesList)
  let searches = a:searchesList
  if a:isFullWord == 1
    let searches = searchalot#addWordBoundries(searches)
  endif
  echom "searches: " . string(searches)

  let grepCmd = searchalot#buildGrepCommand(searches, a:location)

  echomsg "searching:'" . grepCmd . "' using '" . &grepprg . "'"
  execute 'silent ' . grepCmd
  copen " open the results in the quickfix window

  let &grepprg = oldgrepprg
  let &grepformat = orig_grepformat

  if ! exists("g:searchalot_no_highlight")
    :MarkClear
    for curSearch in a:searchesList
      exec ":Mark /" . EscapeForVimRegexp(curSearch) . "/"
    endfor
  endif
endfu

fu! searchalot#buildGrepCommand(searchesList, location)
  let grepCmd = ['grep!']

  let nested = len(a:searchesList) > 1

  if &grepprg == 'internal'
    for curSearch in a:searchesList[0]
      call add(grepCmd, "/" . curSearch . "/j")
    endfor
  else
    for curSearchList in a:searchesList
      if len(grepCmd) > 1 " only true if we encounter a second list
        call add(grepCmd, a:location)
        call add(grepCmd, "\\| rg")
      endif
      for curSearch in curSearchList
        call add(grepCmd, "-e '" . curSearch . "'")
      endfor
    endfor
  endif
  if ! nested
    call add(grepCmd, a:location)
  endif

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
  let processedSearchesList = []
  for curSearchList in a:searchesList
    let currentProcessedSearches = []
    for curSearch in curSearchList
      if &grepprg == 'internal'
        call add(currentProcessedSearches, "\\<" . curSearch . "\\>")
      else
        call add(currentProcessedSearches, "\\b" . curSearch . "\\b")
      endif
    endfor
    call add(processedSearchesList, currentProcessedSearches)
  endfor
  return processedSearchesList
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

