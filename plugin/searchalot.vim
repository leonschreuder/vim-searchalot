" vim-searchalot - Searchin in files, and highlighting the result
" Maintainer:    Leon Schreuder
" Version:       0.1

" if exists("g:loaded_searchalot") && !exists('g:force_reload_ftplug_vim_UT')
"   finish
" endif
" let g:loaded_searchalot = 1

let g:searchalot_searchtools = {
\  'rg': { 'grepprg': 'rg --vimgrep ', 'piped': 'rg' },
\  'grep': { 'grepprg': 'grep -n ', 'grepprgunix': 'grep -n $* /dev/null', 'piped': 'grep' },
\}

" let g:searchalot_force_tool = ""

" search for a specific word as a command
command! -nargs=+ Searcha call Searcha('<args>')
fu! Searcha(...)
  call searchalot#runSearch('*', 0, utl#argparse#SplitArgs(a:1))
endfu

command! -nargs=+ SearchaFile call SearchaFile('<args>')
fu! SearchaFile(filePath, ...)
  call searchalot#runSearch(a:filePath, 0, utl#argparse#SplitArgs(a:1))
endfu

command! -nargs=+ SearchaCurrentFile call SearchaCurrentFile('<args>')
fu! SearchaCurrentFile(...)
  call searchalot#runSearch(expand('%:.'), 0, utl#argparse#SplitArgs(a:1))
endfu

fu! SearchaCurrentWord()
  call searchalot#runSearch("*", 1, [[EscapeForGNURegexp(expand("<cword>"))]])
endfu

fu! SearchaSelectedWord()
  call searchalot#runSearch("*", 0, [[EscapeForGNURegexp(s:get_visual_selection())]])
endfu


fu! searchalot#runSearch(location, isFullWord, searchesList)
  " We use grepprg, but I don't want to change the grepprg permanently in case
  " the user was using it outside of the plugin. The current values are
  " therfore saved and restored wenn we're done.
  let oldgrepprg = &grepprg

  let searchTool = searchalot#getCurrentSearchToolValues()

  let &grepprg = searchTool['grepprg']

  let searches = a:searchesList
  if searchTool['name'] == 'internal'
    let searches = searchalot#performVimRegexEscaping(a:searchesList)
  endif
  if a:isFullWord == 1
    let searches = searchalot#addWordBoundries(searches)
  endif

  let grepCmd = searchalot#buildGrepCommand(searchTool, searches, a:location)

  " echomsg "searching:'" . grepCmd . "' using '" . &grepprg . "'"
  execute 'silent ' . grepCmd
  copen " open the results in the quickfix window

  let &grepprg = oldgrepprg

  if ! exists("g:searchalot_no_highlight")
    :MarkClear
    for curSearchList in a:searchesList
      for curSearch in curSearchList
        exec ":Mark /" . EscapeForVimRegexp(curSearch) . "/"
      endfor
    endfor
  endif
endfu

fu! searchalot#getCurrentSearchToolValues()
  if exists("g:searchalot_force_tool")
    if ! has_key(g:searchalot_searchtools, g:searchalot_force_tool)
      throw "tool '" . g:searchalot_force_tool . "' is not defined in the available tools:" . string(g:searchalot_searchtools)
    elseif exepath(g:searchalot_force_tool) == ""
      throw "tool '" . g:searchalot_force_tool . "' is not found as an executable. Check your path or tool definition."
    else
      let toolconfig = get(g:searchalot_searchtools, g:searchalot_force_tool)
      let toolconfig['name'] = g:searchalot_force_tool
      return toolconfig
    endif
  else
    for tool in keys(g:searchalot_searchtools)
      if exepath(tool) != ""
        let toolconfig = get(g:searchalot_searchtools, tool)
        let toolconfig['name'] = tool
        return toolconfig
      endif
    endfor
  endif
  return {"name": "internal", "grepprg": "internal" } " in case none where found installed on the system
endfu

fu! searchalot#buildGrepCommand(searchTool, searchesList, location)
  let grepCmd = ['grep!']

  let nested = len(a:searchesList) > 1

  if a:searchTool['name'] == 'internal'
    for curSearch in a:searchesList[0]
      call add(grepCmd, "/" . curSearch . "/j")
    endfor
  else
    let index = 0
    while index < len(a:searchesList)
      let curSearchList = a:searchesList[index]

      if index >= 1 " only true if we encounter a second list
        call add(grepCmd, a:location)
        call add(grepCmd, "\\| " . a:searchTool['piped'])
      endif

      for curSearch in curSearchList
        call add(grepCmd, "-e '" . curSearch . "'")
      endfor

      let index = index + 1
    endwhile
  endif
  if ! nested
    call add(grepCmd, a:location)
  endif

  return join(grepCmd, ' ')
endfu

fu! searchalot#performVimRegexEscaping(searchesList)
  let processedSearchesList = []
  for curSearchList in a:searchesList
    let currentProcessedSearches = []
    for curSearch in curSearchList
      call add(currentProcessedSearches, EscapeForVimRegexp(curSearch))
    endfor
    call add(processedSearchesList, currentProcessedSearches)
  endfor
  return processedSearchesList
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

