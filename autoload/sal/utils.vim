
" credit: https://stackoverflow.com/a/61517520/3968618
function! sal#utils#escapeForVimRegexp(str)
  return escape(a:str, '^$.*?/\[]')
endfunction

function! sal#utils#escapeForGNURegexp(str)
  return escape(a:str, '^$.*?/\[]()' . '"' . "'")
endfunction


" Escape each string in the nested list for vims regex syntax
fu! sal#utils#performVimRegexEscaping(searchesList)
  let processedSearchesList = []
  for curSearchList in a:searchesList
    let currentProcessedSearches = []
    for curSearch in curSearchList
      call add(currentProcessedSearches, sal#utils#escapeForVimRegexp(curSearch))
    endfor
    call add(processedSearchesList, currentProcessedSearches)
  endfor
  return processedSearchesList
endfu

" Add the appropriate word boundry to each word for the active search tool
fu! sal#utils#addWordBoundriesToSearch(searchesList)
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


fu! sal#utils#getActiveWindowsInTab()
  let currentTabNr = tabpagenr()
  let tabInfo = gettabinfo(currentTabNr)
  return tabInfo[0]['windows']
endfu

" credit: https://stackoverflow.com/a/6271254/3968618
function! sal#utils#getVisualSelection()
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
