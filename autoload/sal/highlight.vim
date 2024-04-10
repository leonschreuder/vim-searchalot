


fu! sal#highlight#applyHighlighting(searchesList, config)
  windo call clearmatches()
  let matchGroupIndex=0
  for curSearchList in a:searchesList
    for curSearch in curSearchList
      let matchGroupName = "SearchalotMatch" . matchGroupIndex
      call sal#log#debug("highlighting: '" . curSearch . "'", "under matchGroup: " . matchGroupName)
      if sal#search#configIsLocationList(a:config)
        windo call sal#highlight#addInCurrentWindow(curSearch, matchGroupName)
      else
        " after tabdo we will be on the last tabpage instead of the current
        " one. So save the current one before running and switch back after.
        let currentTabNr = tabpagenr()
        tabdo windo call sal#highlight#addInCurrentWindow(curSearch, matchGroupName)
        execute 'tabnext' currentTabNr
      endif
      let matchGroupIndex += 1
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
  call matchadd(a:matchGroup, a:curSearch)
  " TODO: maybe add an autocommand so if a new window is opened in this tab it
  " also has the matches
endfu

fu! sal#highlight#clearHighlighting()
  " TODO: if need to clear only my matches, use `matchdelete()`
  windo call clearmatches()
endfu
