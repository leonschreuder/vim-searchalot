UTSuite main search and helpers

function! s:BeforeAll()
  source autoload/sal/search.vim
endfunction

function s:Test_should_set_grepprg_correctly()

  " no tool forced, finds first existing one
  AssertEquals("rg", sal#search#getCurrentSearchToolValues()['name'])

  let g:searchalot_force_tool = "rg"
  AssertEquals("rg", sal#search#getCurrentSearchToolValues()['name'])

  let g:searchalot_force_tool = "grep"
  AssertEquals("grep", sal#search#getCurrentSearchToolValues()['name'])

  let g:searchalot_force_tool = "undefined"
  AssertThrows sal#search#getCurrentSearchToolValues()

  let old_searchtools = g:searchalot_searchtools
  let g:searchalot_searchtools = { "notinstalled": { "grepprg": "notinstalled" } }
  let g:searchalot_force_tool = "notinstalled"
  AssertThrows sal#search#getCurrentSearchToolValues()
  let g:searchalot_searchtools = old_searchtools
endfunction

function s:Test_should_build_grep_command()
  AssertEquals("grep! -e 'a' *", sal#search#buildGrepCommand({"name": "rg"}, [["a"]], "*"))
  AssertEquals("lgrep! -e 'a' *", sal#search#buildGrepCommand({"name": "rg"}, [["a"]], "*", { "locationlist" : 1 }))
  AssertEquals("grep! -e 'a' -e 'b' *", sal#search#buildGrepCommand({"name": "rg"}, [["a", "b"]], "*"))
  AssertEquals("grep! -e 'a' -e 'b' * \\| rg -e 'c'", sal#search#buildGrepCommand({"name": "rg", "piped": "rg"}, [["a", "b"], ["c"]], "*"))
  AssertEquals("grep! -e 'a' -e 'b' * \\| grep -e 'c'", sal#search#buildGrepCommand({"name": "grep", "piped": "grep"}, [["a", "b"], ["c"]], "*"))
endfunction

function s:Test_should_escape_special_characters()
  AssertEquals("grep! -e 'a\\#b' *", sal#search#buildGrepCommand({"name": "rg"}, [["a#b"]], "*"))
  AssertEquals("grep! -e 'a\\%b' *", sal#search#buildGrepCommand({"name": "rg"}, [["a%b"]], "*"))
endfunction

function s:Test_should_interpret_bang_correctly()
  " when bang is not provided (default), we want highlighting (return 1)
  AssertEquals(1 , sal#search#shouldHighlight(0))
  AssertEquals(0 , sal#search#shouldHighlight(1))

  " when the default is flipped, so do the results
  let g:searchalot_not_highlight_per_default = 1
  AssertEquals(1 , sal#search#shouldHighlight(1))

  " when the default is not flipped (but variable is defined), act like default
  let g:searchalot_not_highlight_per_default = 0
  AssertEquals(1 , sal#search#shouldHighlight(0))
endfunction
