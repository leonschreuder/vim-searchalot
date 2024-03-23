UTSuite Parse it up

function s:Test_split_args()
  AssertEquals([["a", "b", "c"]], sal#argparse#SplitArgs("a b c"))
  AssertEquals([["a", "b", "c"]], sal#argparse#SplitArgs("a 'b' c"))
  AssertEquals([["a", "b 2", "c"]], sal#argparse#SplitArgs("a 'b 2' c"))
  AssertEquals([["a", "b \"2\"", "c"]], sal#argparse#SplitArgs("a 'b \"2\"' c"))
  AssertEquals([["a", "b \'2\'", "c"]], sal#argparse#SplitArgs("a 'b \\'2\\'' c"))
  AssertEquals([["a b", "c"]], sal#argparse#SplitArgs("a\\ b c"))
  AssertEquals([["a", "[b]", "c"]], sal#argparse#SplitArgs("a \\[b\\] c"))
  AssertEquals([["a", "\\", "c"]], sal#argparse#SplitArgs("a \\\\ c"))
endfunction


function s:Test_multiple_commands()
  AssertEquals([["a"], ["c"]], sal#argparse#SplitArgs("'a' | 'c'"))
endfunction
