" vim-searchalot - Search in files, and highlighting the matches
"
" Maintainer:    Leon Schreuder
" Version:       0.1

" Note: The vimdoc is generated from the comments that starts with 3 quotes.

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

fu! searchalot#InWorkingDirToQuickfix(bang, inputString)
  call sal#search#runSearch('*', { "highlight" : sal#search#shouldHighlight(a:bang) }, sal#argparse#SplitArgs(a:inputString))
endfu

""" :Lsearchalot {searches}
""" :Lsal {searches}
""" 
""" Same as |:Sal| but open the result in the location list. Provide a bang
""" (!) for no highlighting.
command! -bang -nargs=+ Lsal call searchalot#InWorkingDirToLinkedList(<bang>0, '<args>')
command! -bang -nargs=+ Lsearchalot call searchalot#InWorkingDirToLinkedList(<bang>0, '<args>')

fu! searchalot#InWorkingDirToLinkedList(bang, inputString)
  call sal#search#runSearch('*', { "highlight" : sal#search#shouldHighlight(a:bang), "locationlist" : 1 }, sal#argparse#SplitArgs(a:inputString))
endfu

""" :SearchalotInFile {file} {searches}
""" :Salf {file} {searches}
""" 
""" Like |:Sal| but searches only the specified file. Results are opend in the
""" quickfix window.
command! -bang -nargs=+ -complete=file Salf call searchalot#InFileToQuickfix(<bang>0, '<args>')
command! -bang -nargs=+ -complete=file SearchalotInFile call searchalot#InFileToQuickfix(<bang>0, '<args>')

fu! searchalot#InFileToQuickfix(bang, inputString)
  let parsed = sal#argparse#SplitArgs(a:inputString)
  " first item as file, then remove the file from the args
  let file = parsed[0][0]
  unlet parsed[0][0]
  call sal#search#runSearch(file, { "highlight" : sal#search#shouldHighlight(a:bang) }, parsed)
endfu

""" :LsearchalotInFile {file} {searches}
""" :Lsalf {file} {searches}
""" 
""" Same as |:Salf| but open the result in the location list.
command! -bang -nargs=+ -complete=file Lsalf call searchalot#InFileToLinkedList(<bang>0, '<args>')
command! -bang -nargs=+ -complete=file LsearchalotInFile call searchalot#InFileToLinkedList(<bang>0, '<args>')

fu! searchalot#InFileToLinkedList(bang, inputString)
  let parsed = sal#argparse#SplitArgs(a:inputString)
  " first item as file, then remove the file from the args
  let file = parsed[0][0]
  unlet parsed[0][0]
  call sal#search#runSearch(file, { "highlight" : sal#search#shouldHighlight(a:bang), "locationlist" : 1 }, parsed)
endfu

""" :SearchalotCurrentFile {searches}
""" :Salc {searches}
""" 
""" Like |:Sal| but searches only the current file. Results are opend in the
""" quickfix window.
command! -bang -nargs=+ Salc call searchalot#InCurrentFileToQuickfix(<bang>0, '<args>')
command! -bang -nargs=+ SearchalotCurrentFile call searchalot#InCurrentFileToQuickfix(<bang>0, '<args>')

fu! searchalot#InCurrentFileToQuickfix(bang, inputString)
  call sal#search#runSearch(expand('%:.'), { "highlight" : sal#search#shouldHighlight(a:bang) }, sal#argparse#SplitArgs(a:inputString))
endfu

""" :LsearchalotCurrentFile {file} {searches}
""" :Lsalc {file} {searches}
""" 
""" Same as |:Salc| but open the result in the location list.
command! -bang -nargs=+ Lsalc call searchalot#InCurrentFileToLocationList(<bang>0, '<args>')
command! -bang -nargs=+ LsearchalotCurrentFile call searchalot#InCurrentFileToLocationList(<bang>0, '<args>')

fu! searchalot#InCurrentFileToLocationList(bang, inputString)
  call sal#search#runSearch(expand('%:.'), { "highlight" : sal#search#shouldHighlight(a:bang), "locationlist" : 1 }, sal#argparse#SplitArgs(a:inputString))
endfu


""" :SalClear
""" :SearchalotClear
"""
""" Clear highlighting
command! SalClear call searchalot#ClearHighlight()
command! SearchalotClear call searchalot#ClearHighlight()

fu! searchalot#ClearHighlight()
  call sal#highlight#clearHighlighting()
endfu


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
  call sal#search#runSearch("*", { "highlight" : 1, "full_word": 1 }, s:current_word_as_search())
endfu

""" SearchalotCurrentWordToQuickfixNoHighlighting()
""" 
""" Same as |SearchalotCurrentWordToQuickfix()| but doesn't highlight the search results.
fu! SearchalotCurrentWordToQuickfixNoHighlighting()
  call sal#search#runSearch("*", { "highlight" : 0, "full_word": 1 }, s:current_word_as_search())
endfu

""" SearchalotCurrentWordToLocation()
""" 
""" Same as |SearchalotCurrentWordToQuickfix()| but
""" opens in the location list. For no highlighting, see
""" |SearchalotCurrentWordToLocationNoHighlighting()|.
fu! SearchalotCurrentWordToLocation()
  call sal#search#runSearch("*", { "highlight" : 1, "full_word": 1, "locationlist" : 1 }, s:current_word_as_search())
endfu

""" SearchalotCurrentWordToLocationNoHighlighting()
""" 
""" Same as |SearchalotCurrentWordToQuickfixNoHighlighting()| but opens in the location
""" list.
fu! SearchalotCurrentWordToLocationNoHighlighting()
  call sal#search#runSearch("*", { "highlight" : 0, "full_word": 1, "locationlist" : 1 }, s:current_word_as_search())
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
  call sal#search#runSearch("*", { "highlight" : 1 }, s:current_selection_as_search())
endfu

""" SearchalotSelectionToQuickfixNoHighlighting()
""" 
""" Same as |SearchalotSelectionToQuickfix()| but doesnt highlight the search results.
fu! SearchalotSelectionToQuickfixNoHighlighting()
  call sal#search#runSearch("*", { "highlight" : 0 }, s:current_selection_as_search())
endfu

""" SearchalotSelectionToLocation()
""" 
""" Same as |SearchalotSelectionToQuickfix()| but opens
""" in the location list. For no highlighting, see
""" |SearchalotSelectionToLocationNoHighlighting()|.
fu! SearchalotSelectionToLocation()
  call sal#search#runSearch("*", { "highlight" : 1, "locationlist" : 1 }, s:current_selection_as_search())
endfu

""" SearchalotSelectionToLocationNoHighlighting()
""" 
""" Same as |SearchalotSelectionToQuickfixNoHighlighting()| but opens in the location list.
fu! SearchalotSelectionToLocationNoHighlighting()
  call sal#search#runSearch("*", { "highlight" : 0, "locationlist" : 1 }, s:current_selection_as_search())
endfu

" Helpers
" ------------------------------------------------------------

fu! s:current_word_as_search()
  return [[sal#utils#escapeForGNURegexp(expand("<cword>"))]]
endfu

fu! s:current_selection_as_search()
  return [[sal#utils#escapeForGNURegexp(sal#utils#getVisualSelection())]]
endfu


" }}}

