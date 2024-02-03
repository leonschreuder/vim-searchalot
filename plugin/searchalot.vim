" vim-searchalot - Search in files, and highlighting the matches
"
" Maintainer:    Leon Schreuder
" Version:       0.1

if exists("g:loaded_searchalot") && !exists('g:searchalot_force_reload')
  finish
endif
let g:loaded_searchalot = 1

let g:searchalot_searchtools = {
\  'rg': { 'grepprg': 'rg --vimgrep --sort path', 'piped': 'rg' },
\  'grep': { 'grepprg': 'grep -n ', 'grepprgunix': 'grep -n $* /dev/null', 'piped': 'grep' },
\}



" COMMANDS
" ================================================================================

""" search for a specific word in the working dir. Open in the quickfix window
command! -nargs=+ Sal call searchalot#InWorkingDirToQuickfix('<args>')
command! -nargs=+ Searchalot call searchalot#InWorkingDirToQuickfix('<args>')
fu! searchalot#InWorkingDirToQuickfix(inputString)
  call searchalot#runSearch('*', {}, utl#argparse#SplitArgs(a:inputString))
endfu

""" search for a specific word in the working dir. Open in the location-list window
command! -nargs=+ Lsal call searchalot#InWorkingDirToLinkedList('<args>')
command! -nargs=+ Lsearchalot call searchalot#InWorkingDirToLinkedList('<args>')

""" Search for a specific word in the specified file. Open in the quickfix window
command! -nargs=+ -complete=file Salf call searchalot#InFileToQuickfix('<args>')
command! -nargs=+ -complete=file SearchalotInFile call searchalot#InFileToQuickfix('<args>')

""" Search for a specific word in the specified file. Open in the location-list window
command! -nargs=+ -complete=file Lsalf call searchalot#InFileToLinkedList('<args>')
command! -nargs=+ -complete=file LsearchalotInFile call searchalot#InFileToLinkedList('<args>')

""" Search for a specific word in the current file. Open in the quickfix window
command! -nargs=+ Salc call searchalot#InCurrentFileToQuickfix('<args>')
command! -nargs=+ SearchalotCurrentFile call searchalot#InCurrentFileToQuickfix('<args>')

""" Search for a specific word in the current file. Open in the location-list window
command! -nargs=+ Lsalc call searchalot#InCurrentFileToLocationList('<args>')
command! -nargs=+ LsearchalotCurrentFile call searchalot#InCurrentFileToLocationList('<args>')


" MAPPING FUNCTIONS
" ================================================================================

""" Search for a specific word under the cursor. Open in the quickfix window
fu! SearchalotCurrentWordToQuickfix()
  call searchalot#runSearch("*", { "full_word": 1 }, s:current_word_as_search())
endfu

""" Search for a specific word under the cursor. Open in the location-list window
fu! SearchalotCurrentWordToLocation()
  call searchalot#runSearch("*", { "full_word": 1, "locationlist" : 1 }, s:current_word_as_search())
endfu

""" Search for selection. Open in the quickfix window
fu! SearchalotSelectionToQuickfix()
  call searchalot#runSearch("*", {}, s:current_selection_as_search())
endfu

""" Search for selection. Open in the location-list window
fu! SearchalotSelectionToLocation()
  call searchalot#runSearch("*", {"locationlist" : 1}, s:current_selection_as_search())
endfu


fu! s:current_word_as_search()
  return [[EscapeForGNURegexp(expand("<cword>"))]]
endfu

fu! s:current_selection_as_search()
  return [[EscapeForGNURegexp(s:get_visual_selection())]]
endfu


" COMMAND RUNNERS
" ================================================================================

fu! searchalot#InWorkingDirToLinkedList(inputString)
  call searchalot#runSearch('*', { "locationlist" : 1 }, utl#argparse#SplitArgs(a:inputString))
endfu

fu! searchalot#InFileToQuickfix(inputString)
  let parsed = utl#argparse#SplitArgs(a:inputString)
  " first item as file, then remove the file from the args
  let file = parsed[0][0]
  unlet parsed[0][0]
  call searchalot#runSearch(file, {}, parsed)
endfu

fu! searchalot#InFileToLinkedList(inputString)
  let parsed = utl#argparse#SplitArgs(a:inputString)
  " first item as file, then remove the file from the args
  let file = parsed[0][0]
  unlet parsed[0][0]
  call searchalot#runSearch(file, { "locationlist" : 1 }, parsed)
endfu

fu! searchalot#InCurrentFileToQuickfix(inputString)
  call searchalot#runSearch(expand('%:.'), {}, utl#argparse#SplitArgs(a:inputString))
endfu

fu! searchalot#InCurrentFileToLocationList(inputString)
  call searchalot#runSearch(expand('%:.'), { "locationlist" : 1 }, utl#argparse#SplitArgs(a:inputString))
endfu


" ACTUAL SEARCHING
" ================================================================================


fu! searchalot#runSearch(location, config, searchesList)
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
  if has_key(a:config, "full_word") && a:config["full_word"] == 1
    let searches = searchalot#addWordBoundries(searches)
  endif

  let grepCmd = searchalot#buildGrepCommand(searchTool, searches, a:location, a:config)

  execute 'silent ' . grepCmd
  copen " open the results in the quickfix window

  let &grepprg = oldgrepprg

  if ! exists("g:searchalot_no_highlight")
    :MarkClear
    for curSearchList in a:searchesList
      for curSearch in curSearchList
        " use 'very magic' so we can mostly use grep-is regexes here
        exec ":Mark /\\v" . curSearch . "/"
      endfor
    endfor
  endif
endfu

" resolve the values of the first match of the search tools configured.
" Repecting g:searchalot_force_tool, or get the first one that is installed
" from the list, while checking if the tool is installed. Fallback to
" 'internal' if no tool could be found.
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

" Escape each string in the nested list for vims regex syntax
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

" Add the appropriate word boundry to each word for the active search tool
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

" The grepprg is set before, and this then builds a :grep 'search' command
" as a string, fitting the provided searchesList
fu! searchalot#buildGrepCommand(searchTool, searchesList, location, config = {})
  let grepCmd = []
  if has_key(a:config, 'locationlist') && a:config['locationlist'] == 1
    call add(grepCmd, 'lgrep!')
  else
    call add(grepCmd, 'grep!')
  endif

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

