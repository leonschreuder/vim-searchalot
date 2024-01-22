UTSuite Parse it up

function s:Test_split_args()
  AssertEquals(["a", "b", "c"], utl#argparse#SplitArgs("a b c"))
  AssertEquals(["a", "b", "c"], utl#argparse#SplitArgs("a 'b' c"))
  AssertEquals(["a", "b 2", "c"], utl#argparse#SplitArgs("a 'b 2' c"))
  AssertEquals(["a", "b \"2\"", "c"], utl#argparse#SplitArgs("a 'b \"2\"' c"))
  AssertEquals(["a", "b \'2\'", "c"], utl#argparse#SplitArgs("a 'b \\'2\\'' c"))
  AssertEquals(["a b", "c"], utl#argparse#SplitArgs("a\\ b c"))
  AssertEquals(["a", "[b]", "c"], utl#argparse#SplitArgs("a \\[b\\] c"))
  AssertEquals(["a", "\\", "c"], utl#argparse#SplitArgs("a \\\\ c"))
endfunction

