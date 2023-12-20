UTSuite Some intelligible name for the suite

function s:Test2()
"   let g:chunkSize="5"
  let tmpdir = substitute(system('mktemp -d'), '\n', '', 'g')
  let tmpfile = tmpdir . '/target.txt'
  echom tmpfile
  call writefile(["line1"], tmpfile, 'a')
  call Find("line1")

  AssertEquals([""], getqflist())
endfunction

" Before:
"   unlet! g:loaded_chunk

" # Test case
" Execute (SearchCwd):
"   let g:chunkSize="5"
"   let tmpdir = substitute(system('mktemp -d'), '\n', '', 'g')
"   let tmpfile = tmpdir . '/target.txt'
"   " echom tmpfile
"   call writefile(["line1"], tmpfile, 'a')
"   call Find("line1")

" Expect:
"   1
"   2
"   3
"   4
"   5
"   6
"   7
"   8
"   9
"   10
"   11
"   12
"   13
"   14
"   15
