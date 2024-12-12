UTSuite Parse it up

function! s:BeforeAll()
  source autoload/sal/argparse.vim
endfunction

function s:Test_should_split_args_respecting_quotes()
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

function s:Test_should_allow_regexes()
  AssertEquals([["[a-c]"]], sal#argparse#SplitArgs("[a-c]"))
  AssertEquals([["\s\d"]], sal#argparse#SplitArgs("\s\d"))
endfunction

function s:Test_should_escape_regexes_in_quoted_strings()
  AssertEquals([["[a-c]"]], sal#argparse#SplitArgs("[a-c]"))
  AssertEquals([['\[a-c\]']], sal#argparse#SplitArgs('"[a-c]"'))
  AssertEquals([['func\(\)']], sal#argparse#SplitArgs('"func()"'))
  AssertEquals([['a\.b\$c']], sal#argparse#SplitArgs('"a.b$c"'))
  AssertEquals([['2\^3\?']], sal#argparse#SplitArgs('"2^3?"'))
  AssertEquals([['win\*\\path']], sal#argparse#SplitArgs('"win*\path"'))
endfunction

function s:Test_should_support_command_separator()
  AssertEquals([["a"], ["c"]], sal#argparse#SplitArgs("'a' | 'c'"))
  AssertEquals([["a|b","c"]], sal#argparse#SplitArgs("a|b 'c'"))
endfunction

function s:Test_should_allow_looping_through_Input()
  let input = sal#argparse#Input("a b")

  AssertEquals(v:true, input.hasNextChar())
  AssertEquals("a", input.popNextChar())
  AssertEquals(v:true, input.hasNextChar())
  AssertEquals(" ", input.popNextChar())
  AssertEquals(v:true, input.hasNextChar())
  AssertEquals("b", input.popNextChar())
  AssertEquals(v:false, input.hasNextChar())
endfunction


function s:Test_should_allow_filling_ParseResult()
  let parseResult = sal#argparse#ParseResult()

  " when - adding a char
  call parseResult.addCharToWord("a")
  " then - should be saved
  AssertEquals(["a"], parseResult.currentParsedWord)

  " when - adding another char
  call parseResult.addCharToWord("b")
  " then - should be saved separately
  AssertEquals(["a","b"], parseResult.currentParsedWord)

  " when - ending the word
  call parseResult.endWord()
  " then - should combine chars and empty word
  AssertEquals([], parseResult.currentParsedWord)
  AssertEquals(["ab"], parseResult.parsedArgsGroup)

  " when - adding a second word
  call parseResult.addCharToWord("c")
  call parseResult.addCharToWord("d")
  call parseResult.endWord()
  " then - should add to list
  AssertEquals(["ab", "cd"], parseResult.parsedArgsGroup)

  " when - ending group
  call parseResult.endGroup()
  " then - should put groups into another list
  AssertEquals([], parseResult.currentParsedWord)
  AssertEquals([], parseResult.parsedArgsGroup)
  AssertEquals([["ab", "cd"]], parseResult.parsedArgsGroupList)
endfunction

function s:Test_should_allow_parsing_quotes_with_ParseResult()
  let parseResult = sal#argparse#ParseResult()
  call parseResult.addCharToWord("a")
  call parseResult.addCharToWord("b")
  call parseResult.endWord()

  " then - default is not in quote
  AssertEquals(v:false, parseResult.isInQuote())
  AssertEquals(v:false, parseResult.isClosingQuote("x"))
  AssertEquals(v:false, parseResult.isClosingQuote("'"))

  " when - adding a char
  call parseResult.openQuote("'")
  " then - should be saved and checked correctly
  AssertEquals(v:true, parseResult.isInQuote())
  AssertEquals(v:false, parseResult.isClosingQuote("x"))
  AssertEquals(v:true, parseResult.isClosingQuote("'"))

  " when - closing quote
  call parseResult.closeQuote()
  " then - should respond correctly
  AssertEquals(v:false, parseResult.isInQuote())
  AssertEquals(v:false, parseResult.isClosingQuote("x"))
  AssertEquals(v:false, parseResult.isClosingQuote("'"))
endfunction
