UTSuite The basics

let g:orig_cwd = getcwd()
let g:tmpdir = ""

let g:searchalot_no_highlight = 1
let g:searchalot_force_reload = 1

function! s:Setup()
  " in order to search in an isolated 'workspace' create some tmp stuff
  let g:tmpdir = substitute(system('mktemp -d'), '\n', '', 'g')
  " isolate and redirect in vim
  if exists("g:searchalot_force_tool")
    unlet g:searchalot_force_tool " in case was set
  endif
 
  tabe " open a new tab
  " change the working dir of the whole tab to the temp location
  exec "tcd " . g:tmpdir
endfunction

function! s:Teardown()
  cclose " close quickfix in case it's still open from searching
  silent! bw! " close 'tmp' buffer opened with edit
  call system('rm -rf' . g:tmpdir) " remove entire tmp folder
endfunction


function s:Test_should_perform_general_find()
  call writefile(["line1"], g:tmpdir . '/target.txt', 'a')
  
  call Searcha("line1")

  let qflist = getqflist()
  AssertEquals(1 , len(qflist))
  AssertEquals('1:line1' , qflist[0].text)
endfunction

function s:Test_should_perform_find_for_all_defined_searchtools()
  call writefile(["line1"], g:tmpdir . '/target.txt', 'a')

  for searchtoolname in keys(g:searchalot_searchtools)
    let g:searchalot_force_tool = searchtoolname
    call Searcha("line1")
    let qflist = getqflist()
    AssertEquals(1 , len(qflist))
    AssertEquals('1:line1' , qflist[0].text)
  endfor

endfunction

function s:Test_should_set_grepprg_correctly()

  " no tool forced, finds first existing one
  AssertEquals("rg", searchalot#getCurrentSearchToolValues()['name'])

  let g:searchalot_force_tool = "rg"
  AssertEquals("rg", searchalot#getCurrentSearchToolValues()['name'])

  let g:searchalot_force_tool = "grep"
  AssertEquals("grep", searchalot#getCurrentSearchToolValues()['name'])

  let g:searchalot_force_tool = "undefined"
  AssertThrows searchalot#getCurrentSearchToolValues()

  let old_searchtools = g:searchalot_searchtools
  let g:searchalot_searchtools = { "notinstalled": { "grepprg": "notinstalled" } }
  let g:searchalot_force_tool = "notinstalled"
  AssertThrows searchalot#getCurrentSearchToolValues()
  let g:searchalot_searchtools = old_searchtools
endfunction

function s:Test_should_perform_escaping_for_internal()
  AssertEquals([["a\\$b"]], searchalot#performVimRegexEscaping([["a$b"]]))
endfunction

function s:Test_should_add_word_boundries_for_whole_words()
  let oldgrepprg = &grepprg
  let &grepprg = 'internal'
  AssertEquals([["\\<a\\>", "\\<b\\>"], ["\\<c\\>"]], searchalot#addWordBoundries([["a", "b"], ["c"]]))
  let &grepprg = 'rg'
  AssertEquals([["\\ba\\b", "\\bb\\b"], ["\\bc\\b"]], searchalot#addWordBoundries([["a", "b"], ["c"]]))
  let &grepprg = oldgrepprg
endfunction

function s:Test_should_build_grep_command()
  AssertEquals("grep! -e 'a' *", searchalot#buildGrepCommand({"name": "rg"}, [["a"]], "*"))
  AssertEquals("grep! -e 'a' -e 'b' *", searchalot#buildGrepCommand({"name": "rg"}, [["a", "b"]], "*"))
  AssertEquals("grep! -e 'a' -e 'b' * \\| rg -e 'c'", searchalot#buildGrepCommand({"name": "rg", "piped": "rg"}, [["a", "b"], ["c"]], "*"))
  AssertEquals("grep! -e 'a' -e 'b' * \\| grep -e 'c'", searchalot#buildGrepCommand({"name": "grep", "piped": "grep"}, [["a", "b"], ["c"]], "*"))
endfunction

function s:Test_find_should_allow_multiple_searches()
  call writefile(["line1","line2"], g:tmpdir . '/target.txt', 'a')
  
  call Searcha("line1 \"line2\"")

  let qflist = getqflist()
  AssertEquals(2 , len(qflist))
  AssertEquals(1 , qflist[0].lnum)
endfunction


function s:Test_shoud_find_in_file()
  let tmpfile = g:tmpdir . '/target.txt'
  call writefile(["line1"], tmpfile, 'a')
  
  call SearchaFile(tmpfile, "line1")

  let qflist = getqflist()
  AssertEquals(1 , len(qflist))
  AssertEquals(1 , qflist[0].lnum)
  AssertEquals('1:line1' , qflist[0].text)
endfunction


function s:Test_shoud_find_in_current_file()
  let tmpfile = g:tmpdir . '/target.txt'
  call writefile(["line1"], tmpfile, 'a')
  exec ':e ' . tmpfile
  
  call SearchaCurrentFile("line1")

  let qflist = getqflist()
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
  
  call SearchaCurrentWord() " should be on line1

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
  
  call SearchaSelectedWord()

  let qflist = getqflist()
  AssertEquals(1 , len(qflist))
  AssertEquals(4 , qflist[0].lnum)
  AssertEquals('1:line4' , qflist[0].text)
endfunction

function s:Test_find_should_allow_stacked_searches_which_research_on_matches()
  call writefile(["line1","line2", "thing2"], g:tmpdir . '/target.txt', 'a')
  
  call Searcha("line | 2")

  let qflist = getqflist()
  AssertEquals(1 , len(qflist))
  AssertEquals(2 , qflist[0].lnum)
  AssertEquals('1:line2' , qflist[0].text)
endfunction
