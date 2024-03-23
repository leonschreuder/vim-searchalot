UTSuite utility functtionality

function! s:BeforeAll()
  source autoload/sal/utils.vim
endfunction


function s:Test_should_add_word_boundries_for_whole_words()
  let oldgrepprg = &grepprg
  let &grepprg = 'internal'
  AssertEquals([["\\<a\\>", "\\<b\\>"], ["\\<c\\>"]], sal#utils#addWordBoundriesToSearch([["a", "b"], ["c"]]))
  let &grepprg = 'rg'
  AssertEquals([["\\ba\\b", "\\bb\\b"], ["\\bc\\b"]], sal#utils#addWordBoundriesToSearch([["a", "b"], ["c"]]))
  let &grepprg = oldgrepprg
endfunction
