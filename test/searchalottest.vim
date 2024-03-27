UTSuite The basics

let g:orig_cwd = getcwd()
let g:tmpdir = ""

let g:searchalot_force_reload = 1

" TODO:
" + replace :Mark with direct function calls
"   + support matchadd()
"   + add custom colors (template from :Mark?)
"   + tryout and tweak
" + add command to clear highlighting
" + refactor (too many functions in the main script)
" + optimize using autoload directory
" + add :SalClear - to clear highlighting
" - add debug logging using log()
" - better error messages
"   - empty search string (when quoteing)
"   - missing file for Salf (only search string should be missing search string)

" SETUP
" ================================================================================

function! s:BeforeAll()
  source plugin/searchalot.vim
endfunction

function! s:Setup()
  " in order to search in an isolated 'workspace' create some tmp stuff
  let g:tmpdir = substitute(system('mktemp -d'), '\n', '', 'g')
  " isolate and redirect in vim
  if exists("g:searchalot_force_tool")
    unlet g:searchalot_force_tool " in case was set
  endif
  if exists("g:searchalot_not_highlight_per_default")
    unlet g:searchalot_not_highlight_per_default
  endif
  call s:mockPerformHighlighting()

  let g:perform_highlighting_mock_called = 0

  tabe " open a new tab
  " change the working dir of the whole tab to the temp location
  exec "tcd " . g:tmpdir
endfunction

function! s:Teardown()
  cclose " close quickfix in case it's still open from searching
  lclose
  bw! " close 'tmp' buffer opened with edit
  call system('rm -rf' . g:tmpdir) " remove entire tmp folder
endfunction


" TESTS
" ================================================================================

function s:Test_should_perform_general_find()
  " given
  call writefile(["line1"], g:tmpdir . '/target.txt', 'a')
  call s:mockPerformHighlighting()

  " when
  :Searchalot "line1"

  " then
  let qflist = getqflist()
  AssertEquals(1 , len(qflist))
  AssertEquals('1:line1' , qflist[0].text)
  AssertEquals(1 , g:perform_highlighting_mock_called)

  " given
  call s:mockPerformHighlighting()

  " when
  :Lsearchalot "line1"

  " then
  let llist = getloclist(win_getid())
  AssertEquals(1 , len(llist))
  AssertEquals(1 , g:perform_highlighting_mock_called)
  AssertEquals('1:line1' , llist[0].text)
  AssertEquals(1 , g:perform_highlighting_mock_called)
endfunction

function s:Test_should_perform_find_for_all_defined_searchtools()
  call writefile(["line1"], g:tmpdir . '/target.txt', 'a')

  for searchtoolname in keys(g:searchalot_searchtools)
    call s:mockPerformHighlighting()
    let g:searchalot_force_tool = searchtoolname

    :Searchalot "line1"

    let qflist = getqflist()
    AssertEquals(1 , len(qflist))
    AssertEquals('1:line1' , qflist[0].text)
  endfor

endfunction

function s:Test_should_perform_escaping_for_internal()
  AssertEquals([["a\\$b"]], sal#utils#performVimRegexEscaping([["a$b"]]))
endfunction

function s:Test_find_should_allow_multiple_searches()
  call writefile(["line1","line2"], g:tmpdir . '/target.txt', 'a')

  :Searchalot line1 "line2"

  let qflist = getqflist()
  AssertEquals(2 , len(qflist))
  AssertEquals(1 , qflist[0].lnum)
endfunction

function s:Test_find_should_allow_stacked_searches_which_research_on_matches()
  call writefile(["line1","line2", "thing2"], g:tmpdir . '/target.txt', 'a')

  :Searchalot line | 2

  let qflist = getqflist()
  AssertEquals(1 , len(qflist))
  AssertEquals(2 , qflist[0].lnum)
  AssertEquals('1:line2' , qflist[0].text)
endfunction


function s:Test_shoud_find_in_file()
  let tmpfile = g:tmpdir . '/target.txt'
  call writefile(["line1"], tmpfile, 'a')
  let g:perform_highlighting_mock_called = 0

  exec ":SearchalotInFile!" . tmpfile . " line1 \"line2\""

  let qflist = getqflist()
  AssertEquals(0 , g:perform_highlighting_mock_called)
  AssertEquals(1 , len(qflist))
  AssertEquals(1 , qflist[0].lnum)
  AssertEquals('1:line1' , qflist[0].text)
endfunction


function s:Test_shoud_find_in_current_file()
  let tmpfile = g:tmpdir . '/target.txt'
  call writefile(["line1"], tmpfile, 'a')
  exec ':e ' . tmpfile
  let g:perform_highlighting_mock_called = 0

  :SearchalotCurrentFile "line1"

  let qflist = getqflist()
  AssertEquals(1 , g:perform_highlighting_mock_called)
  AssertEquals(1 , len(qflist))
  AssertEquals(1 , qflist[0].lnum)
  AssertEquals('1:line1' , qflist[0].text)
endfunction

function s:Test_shoud_find_current_word()
  call writefile(["line1","line2"], g:tmpdir . '/target.txt', 'a')
  SetBufferContent << trim EOF
  line1
  line2

  line4
  EOF
  " move down 1 line
  :normal j

  call SearchalotCurrentWordToQuickfix() " should be on line1

  let qflist = getqflist()
  AssertEquals(1 , len(qflist))
  AssertEquals(2 , qflist[0].lnum)
  AssertEquals('1:line2' , qflist[0].text)
endfunction

function s:Test_shoud_find_selected_word()
  call writefile(["line1","line2","line3","line4"], g:tmpdir . '/target.txt', 'a')
  SetBufferContent << trim EOF
  line1
  line2

  line4
  EOF
  " move down 1 line
  :normal 3j
  " select and copy (needs to make getting the selection work for some reason)
  :normal vey

  call SearchalotSelectionToQuickfix()

  let qflist = getqflist()
  AssertEquals(1 , len(qflist))
  AssertEquals(4 , qflist[0].lnum)
  AssertEquals('1:line4' , qflist[0].text)
endfunction


function! s:mockPerformHighlighting()
  let g:perform_highlighting_mock_called = 0
  fu! sal#highlight#applyHighlighting(searchesList, config)
    let g:perform_highlighting_mock_called = 1
  endfu
endfunction
