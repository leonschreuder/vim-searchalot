
" main search functionality
fu! sal#search#runSearch(location, config, searchesList)
  " We use grepprg, but I don't want to change the grepprg permanently in case
  " the user was using it outside of the plugin. The current values are
  " therfore saved and restored wenn we're done.
  let oldgrepprg = &grepprg
  call sal#log#debug("config:", string(a:config))

  let searchTool = sal#search#getCurrentSearchToolValues()
  call sal#log#debug("searchtool:", string(searchTool))

  let &grepprg = searchTool['grepprg']

  let searches = a:searchesList
  if searchTool['name'] == 'internal'
    let searches = sal#utils#performVimRegexEscaping(a:searchesList)
  endif
  if sal#search#configIsFullWord(a:config)
    let searches = sal#utils#addWordBoundriesToSearch(searches)
  endif

  let grepCmd = sal#search#buildGrepCommand(searchTool, searches, a:location, a:config)
  call sal#log#debug("grepCmd:", grepCmd)

  execute 'silent ' . grepCmd
  if sal#search#configIsLocationList(a:config)
    lopen  " open the results in the locationlist window
  else
    copen " open the results in the quickfix window
  endif

  let &grepprg = oldgrepprg

  if has_key(a:config, 'highlight') && a:config['highlight'] == 1
    call sal#highlight#applyHighlighting(a:searchesList, a:config)
  endif
endfu

" resolve the values of the first match of the search tools configured.
" Repecting g:searchalot_force_tool, or get the first one that is installed
" from the list, while checking if the tool is installed. Fallback to
" 'internal' if no tool could be found.
fu! sal#search#getCurrentSearchToolValues()
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

" The grepprg is set before, and this then builds a :grep 'search' command
" as a string, fitting the provided searchesList
fu! sal#search#buildGrepCommand(searchTool, searchesList, location, config = {})
  let grepCmd = []
  if sal#search#configIsLocationList(a:config)
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
      call add(grepCmd, "/" . sal#utils#escapeForGrepprg(curSearch) . "/j")
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
        call add(grepCmd, "-e '" . sal#utils#escapeForGrepprg(curSearch) . "'")
      endfor

      let index = index + 1
    endwhile
  endif
  if ! nested
    call add(grepCmd, a:location)
  endif

  return join(grepCmd, ' ')
endfu

" check if should highlight depending on bang and environment variables
fu! sal#search#shouldHighlight(bang)
  if exists("g:searchalot_not_highlight_per_default") && g:searchalot_not_highlight_per_default == 1
    return a:bang
  else
    return !a:bang
  endif
endfu

fu! sal#search#configIsLocationList(config)
  return has_key(a:config, 'locationlist') && a:config['locationlist'] == 1
endfu

fu! sal#search#configIsFullWord(config)
  return has_key(a:config, "full_word") && a:config["full_word"] == 1
endfu

