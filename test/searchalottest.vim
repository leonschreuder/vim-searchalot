UTSuite The basics

let g:orig_cwd = getcwd()
let g:tmpdir = ""

let g:searchalot_no_highlight = 1

function! s:Setup()
  " in order to search in an isolated 'workspace' create some tmp stuff
  let g:tmpdir = substitute(system('mktemp -d'), '\n', '', 'g')
  " isolate and redirect in vim
 
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
  AssertEquals(1 , qflist[0].lnum)
  AssertEquals('1:line1' , qflist[0].text)
endfunction

function s:Test_find_should_allow_multiple_searches()
  call writefile(["line1","line2"], g:tmpdir . '/target.txt', 'a')
  
  call Searcha("line1 \"line2\"")

  let qflist = getqflist()
  AssertEquals(2 , len(qflist))
  AssertEquals(1 , qflist[0].lnum)
  " AssertEquals(2 , qflist[1].lnum)
  " AssertEquals('1:line1' , qflist[0].text)
  " AssertEquals('1:line2' , qflist[1].text)
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

function s:Test_split_args()
  AssertEquals(["a", "b", "c"], SplitArgs("a b c"))
  AssertEquals(["a", "b", "c"], SplitArgs("a 'b' c"))
  AssertEquals(["a", "b 2", "c"], SplitArgs("a 'b 2' c"))
  AssertEquals(["a", "b \"2\"", "c"], SplitArgs("a 'b \"2\"' c"))
  AssertEquals(["a", "b \'2\'", "c"], SplitArgs("a 'b \\'2\\'' c"))
  AssertEquals(["a b", "c"], SplitArgs("a\\ b c"))
endfunction
