" vim-searchalot - Search in files, and highlighting the matches
"
" Maintainer:    Leon Schreuder
" Version:       0.1

if exists("g:loaded_searchalot") && !exists('g:searchalot_force_reload')
  finish
endif
let g:loaded_searchalot = 1

""" g:searchalot_searchtools
"""
""" |Dictionary| of search tools and their precedence to use. See the example
""" below or for all default options, see the top of the plugin/searchalot.vim
""" file. You can configure your own searchtools by setting the property in your
""" vimrc.
"""
"""     let g:searchalot_searchtools = {
"""     \  'rg': { 'grepprg': 'rg --vimgrep ', 'piped': 'rg' },
"""     \}
"""
let g:searchalot_searchtools = {
\  'rg': { 'grepprg': 'rg --vimgrep --sort path', 'piped': 'rg' },
\  'grep': { 'grepprg': 'grep -n ', 'grepprgunix': 'grep -n $* /dev/null', 'piped': 'grep' },
\}

""" g:searchalot_force_tool
"""
""" If you prefer to use a certain tool over another one, but the other one is
""" higher in the list, you can either change the |g:searchalot_searchtools|
""" variable or set this variable to the string name of the tool to specify
""" the one you want to use.

""" g:searchalot_not_highlight_per_default
"""
""" Normally, the results of the commands are also highlighted, unless a bang
""" (!) is added to a command. Depending on your usecase though, you might
""" not want to highlight the results usually. You can set this variable to
""" 1 to simply flip the usage of the bang, so it will ONLY highlight the
""" results when a bang is provided. This variable has no effect on the custom
""" functions, as highlighting is explicitly provided or prevented by the
""" respective function.

" COMMANDS
" ================================================================================

""" :Searchalot {searches}
""" :Sal {searches}
""" 
""" Run a search through all files in the current working directory. This
""" works similar to running `grep {searches} *` but with the fastest searcher
""" available on your system. The results will also be highilghted unless a
""" bang (!) is provided. Multiple string-separated searches can be added, and
""" each will be searched and highlighted. If a pipe is added, it will first
""" search for everything before the pipe, and run the search again on the
""" matches of the first. This is similar to grepping, and then piping the
""" result in another grep to refine your search. For example:  
""" `:Sal "prefix" | "specific thing"`  
""" This will first search for the prefix, and then run a search for "specific
""" thing" on all matches of the first search. Results are opend in the
""" quickfix window.
command! -bang -nargs=+ Sal call searchalot#InWorkingDirToQuickfix(<bang>0, '<args>')
command! -bang -nargs=+ Searchalot call searchalot#InWorkingDirToQuickfix(<bang>0, '<args>')

""" :Lsearchalot {searches}
""" :Lsal {searches}
""" 
""" Same as |:Sal| but open the result in the location list. Provide a bang
""" (!) for no highlighting.
command! -bang -nargs=+ Lsal call searchalot#InWorkingDirToLinkedList(<bang>0, '<args>')
command! -bang -nargs=+ Lsearchalot call searchalot#InWorkingDirToLinkedList(<bang>0, '<args>')

""" :SearchalotInFile {file} {searches}
""" :Salf {file} {searches}
""" 
""" Like |:Sal| but searches only the specified file. Results are opend in the
""" quickfix window.
command! -bang -nargs=+ -complete=file Salf call searchalot#InFileToQuickfix(<bang>0, '<args>')
command! -bang -nargs=+ -complete=file SearchalotInFile call searchalot#InFileToQuickfix(<bang>0, '<args>')

""" :LsearchalotInFile {file} {searches}
""" :Lsalf {file} {searches}
""" 
""" Same as |:Salf| but open the result in the location list.
command! -bang -nargs=+ -complete=file Lsalf call searchalot#InFileToLinkedList(<bang>0, '<args>')
command! -bang -nargs=+ -complete=file LsearchalotInFile call searchalot#InFileToLinkedList(<bang>0, '<args>')

""" :SearchalotCurrentFile {searches}
""" :Salc {searches}
""" 
""" Like |:Sal| but searches only the current file. Results are opend in the
""" quickfix window.
command! -bang -nargs=+ Salc call searchalot#InCurrentFileToQuickfix(<bang>0, '<args>')
command! -bang -nargs=+ SearchalotCurrentFile call searchalot#InCurrentFileToQuickfix(<bang>0, '<args>')

""" :LsearchalotCurrentFile {file} {searches}
""" :Lsalc {file} {searches}
""" 
""" Same as |:Salc| but open the result in the location list.
command! -bang -nargs=+ Lsalc call searchalot#InCurrentFileToLocationList(<bang>0, '<args>')
command! -bang -nargs=+ LsearchalotCurrentFile call searchalot#InCurrentFileToLocationList(<bang>0, '<args>')


" MAPPING FUNCTIONS
" ================================================================================

" Current word
" ------------------------------------------------------------

""" SearchalotCurrentWordToQuickfix()
"""
""" Function you can use in a mapping to search for the word under
""" the cursor. It works like |:Sal| and searches all files in the
""" working dir and any subdirectory. Opens in the quickfix window. See
""" |getting-started| for an example of such a mapping. For no highlighting,
""" see |SearchalotCurrentWordToQuickfixNoHighlighting()|.
fu! SearchalotCurrentWordToQuickfix()
  call searchalot#runSearch("*", { "highlight" : 1, "full_word": 1 }, s:current_word_as_search())
endfu

""" SearchalotCurrentWordToQuickfixNoHighlighting()
""" 
""" Same as |SearchalotCurrentWordToQuickfix()| but doesn't highlight the search results.
fu! SearchalotCurrentWordToQuickfixNoHighlighting()
  call searchalot#runSearch("*", { "highlight" : 0, "full_word": 1 }, s:current_word_as_search())
endfu

""" SearchalotCurrentWordToLocation()
""" 
""" Same as |SearchalotCurrentWordToQuickfix()| but
""" opens in the location list. For no highlighting, see
""" |SearchalotCurrentWordToLocationNoHighlighting()|.
fu! SearchalotCurrentWordToLocation()
  call searchalot#runSearch("*", { "highlight" : 1, "full_word": 1, "locationlist" : 1 }, s:current_word_as_search())
endfu

""" SearchalotCurrentWordToLocationNoHighlighting()
""" 
""" Same as |SearchalotCurrentWordToQuickfixNoHighlighting()| but opens in the location
""" list.
fu! SearchalotCurrentWordToLocationNoHighlighting()
  call searchalot#runSearch("*", { "highlight" : 0, "full_word": 1, "locationlist" : 1 }, s:current_word_as_search())
endfu

" Selection
" ------------------------------------------------------------

""" SearchalotSelectionToQuickfix()
""" 
""" Function you can use in a mapping to search for the selection. It
""" works like |:Sal| and searches all files in the working dir and any
""" subdirectory. Opens in the location list. See |getting-started|
""" for an example of such a mapping. For no highlighting, see
""" |SearchalotSelectionToQuickfixNoHighlighting()|.
fu! SearchalotSelectionToQuickfix()
  call searchalot#runSearch("*", { "highlight" : 1 }, s:current_selection_as_search())
endfu

""" SearchalotSelectionToQuickfixNoHighlighting()
""" 
""" Same as |SearchalotSelectionToQuickfix()| but doesnt highlight the search results.
fu! SearchalotSelectionToQuickfixNoHighlighting()
  call searchalot#runSearch("*", { "highlight" : 0 }, s:current_selection_as_search())
endfu

""" SearchalotSelectionToLocation()
""" 
""" Same as |SearchalotSelectionToQuickfix()| but opens
""" in the location list. For no highlighting, see
""" |SearchalotSelectionToLocationNoHighlighting()|.
fu! SearchalotSelectionToLocation()
  call searchalot#runSearch("*", { "highlight" : 1, "locationlist" : 1 }, s:current_selection_as_search())
endfu

""" SearchalotSelectionToLocationNoHighlighting()
""" 
""" Same as |SearchalotSelectionToQuickfixNoHighlighting()| but opens in the location list.
fu! SearchalotSelectionToLocationNoHighlighting()
  call searchalot#runSearch("*", { "highlight" : 0, "locationlist" : 1 }, s:current_selection_as_search())
endfu

" Helpers
" ------------------------------------------------------------

fu! s:current_word_as_search()
  return [[EscapeForGNURegexp(expand("<cword>"))]]
endfu

fu! s:current_selection_as_search()
  return [[EscapeForGNURegexp(s:get_visual_selection())]]
endfu


" COMMAND RUNNERS
" ================================================================================

fu! searchalot#InWorkingDirToQuickfix(bang, inputString)
  call searchalot#runSearch('*', { "highlight" : searchalot#internal_should_highlight(a:bang) }, utl#argparse#SplitArgs(a:inputString))
endfu

fu! searchalot#InWorkingDirToLinkedList(bang, inputString)
  call searchalot#runSearch('*', { "highlight" : searchalot#internal_should_highlight(a:bang), "locationlist" : 1 }, utl#argparse#SplitArgs(a:inputString))
endfu

fu! searchalot#InFileToQuickfix(bang, inputString)
  let parsed = utl#argparse#SplitArgs(a:inputString)
  " first item as file, then remove the file from the args
  let file = parsed[0][0]
  unlet parsed[0][0]
  call searchalot#runSearch(file, { "highlight" : searchalot#internal_should_highlight(a:bang) }, parsed)
endfu

fu! searchalot#InFileToLinkedList(bang, inputString)
  let parsed = utl#argparse#SplitArgs(a:inputString)
  " first item as file, then remove the file from the args
  let file = parsed[0][0]
  unlet parsed[0][0]
  call searchalot#runSearch(file, { "highlight" : searchalot#internal_should_highlight(a:bang), "locationlist" : 1 }, parsed)
endfu

fu! searchalot#InCurrentFileToQuickfix(bang, inputString)
  call searchalot#runSearch(expand('%:.'), { "highlight" : searchalot#internal_should_highlight(a:bang) }, utl#argparse#SplitArgs(a:inputString))
endfu

fu! searchalot#InCurrentFileToLocationList(bang, inputString)
  call searchalot#runSearch(expand('%:.'), { "highlight" : searchalot#internal_should_highlight(a:bang), "locationlist" : 1 }, utl#argparse#SplitArgs(a:inputString))
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
  if s:configIsFullWord(a:config)
    let searches = searchalot#addWordBoundries(searches)
  endif

  let grepCmd = searchalot#buildGrepCommand(searchTool, searches, a:location, a:config)

  execute 'silent ' . grepCmd
  if s:configIsLocationList(a:config)
    lopen  " open the results in the locationlist window
  else
    copen " open the results in the quickfix window
  endif

  let &grepprg = oldgrepprg

  if searchalot#shouldHighlight(a:config)
    call searchalot#performHighlighting(a:searchesList)
  endif
endfu

fu! searchalot#shouldHighlight(config)
  return has_key(a:config, 'highlight') && a:config['highlight'] == 1
endfu

fu! searchalot#performHighlighting(searchesList)
  :MarkClear
  for curSearchList in a:searchesList
    for curSearch in curSearchList
      " use 'very magic' so we can mostly use grep-is regexes here
      exec ":Mark /\\v" . curSearch . "/"
    endfor
  endfor
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
  if s:configIsLocationList(a:config)
    call add(grepCmd, 'lgrep!')
  else
    call add(grepCmd, 'grep!')
  endif

  let nested = len(a:searchesList) > 1

  if a:searchTool['name'] == 'internal'
    if nested
      throw "Nested searches are not supported for internal vimgrep"
    endif
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

" Helper functions
" ------------------------------------------------------------

" credit: https://stackoverflow.com/a/61517520/3968618
function! EscapeForVimRegexp(str)
  return escape(a:str, '^$.*?/\[]')
endfunction
function! EscapeForGNURegexp(str)
  return escape(a:str, '^$.*?/\[]()' . '"' . "'")
endfunction

" check if should highlight depending on bang and environment variables
fu! searchalot#internal_should_highlight(bang)
  if exists("g:searchalot_not_highlight_per_default") && g:searchalot_not_highlight_per_default == 1
    return !a:bang
  else
    return a:bang
  endif
endfu

fu! s:configIsLocationList(config)
  return has_key(a:config, 'locationlist') && a:config['locationlist'] == 1
endfu

fu! s:configIsFullWord(config)
  return has_key(a:config, "full_word") && a:config["full_word"] == 1
endfu

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

