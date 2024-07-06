UTSuite Parse it up

function! s:BeforeAll()
  source autoload/sal/argparse.vim
endfunction

function s:Test_split_args()
  AssertEquals([["a", "b", "c"]], sal#argparse#SplitArgs("a b c"))
  AssertEquals([["a", "b", "c"]], sal#argparse#SplitArgs("a 'b' c"))
  AssertEquals([["a", "b 2", "c"]], sal#argparse#SplitArgs("a 'b 2' c"))
  " other quote type inside quote is part of the single string
  AssertEquals([["a", 'b "2"', "c"]], sal#argparse#SplitArgs("a 'b \"2\"' c"))
  " escaped quotes inside quotes are honored
  AssertEquals([["a", "b \\'2\\'", "c"]], sal#argparse#SplitArgs("a 'b \\'2\\'' c"))
  " escaped space will make this part of the string
  AssertEquals([["a b", "c"]], sal#argparse#SplitArgs("a\\ b c"))
  AssertEquals([["a", "[b]", "c"]], sal#argparse#SplitArgs("a \\[b\\] c"))
  AssertEquals([["a", "\\", "c"]], sal#argparse#SplitArgs("a \\\\ c"))
endfunction

function s:Test_split_args_for_regex()
  AssertEquals([["[a-c]"]], sal#argparse#SplitArgs("[a-c]"))
  AssertEquals([['\[a-c\]']], sal#argparse#SplitArgs('"[a-c]"'))
  AssertEquals([['func\(\)']], sal#argparse#SplitArgs('"func()"'))
  AssertEquals([['a\.b\$c']], sal#argparse#SplitArgs('"a.b$c"'))
  AssertEquals([['2\^3\?']], sal#argparse#SplitArgs('"2^3?"'))
  AssertEquals([['win\*\\path']], sal#argparse#SplitArgs('"win*\path"'))
endfunction


function s:Test_multiple_commands()
  AssertEquals([["a"], ["c"]], sal#argparse#SplitArgs("'a' | 'c'"))
endfunction
