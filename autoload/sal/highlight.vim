


fu! sal#highlight#applyHighlighting(searchesList, config)
  windo call clearmatches()
  let matchGroupIndex=0
  for curSearchList in a:searchesList
    for curSearch in curSearchList
      if sal#search#configIsLocationList(a:config)
        windo call sal#highlight#addInCurrentWindow(curSearch, "SearchalotMatch".matchGroupIndex)
        let matchGroupIndex += 1
      else
        tabdo windo call sal#highlight#addInCurrentWindow(curSearch, "SearchalotMatch".matchGroupIndex)
        let matchGroupIndex += 1
      endif
    endfor
  endfor
endfu


" each window has to be treated separately. Call with `windo` to run on all
fu! sal#highlight#addInCurrentWindow(curSearch, matchGroup)
  " TODO: should I save only my matches in case someone has other custom matches?
  " if !exists("w:searchalot_highlighted")
  "   let w:searchalot_highlighted = []
  " endif
  " call add(w:searchalot_highlighted, matchadd('CurSearch', a:curSearch))
  echom "matchGroup:".a:matchGroup
  call matchadd(a:matchGroup, a:curSearch)
  " TODO: maybe add an autocommand so if a new window is opened in this tab it
  " also has the matches
endfu

fu! sal#highlight#clearInCurrentWindow()
  # TODO: if need to clear only my matches, use `matchdelete()`
  call clearmatches()
endfu

