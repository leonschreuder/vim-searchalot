
" Logs to :echomsg unless g:searchalot_log_quiet is defined
fu sal#log#msg(...)
  if !exists("g:searchalot_log_quiet")
    echom "[searchalot] " . join(a:000)
  endif
endfu

" Logs to :echomsg but only when g:searchalot_log_debug is defined
fu sal#log#debug(...)
  if exists("g:searchalot_log_debug")
    echom "[searchalot] " . join(a:000)
  endif
endfu
