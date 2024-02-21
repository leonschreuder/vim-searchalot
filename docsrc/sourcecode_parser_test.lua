local luaunit = require('luaunit')

require('sourcecode_parser')

function Test_should_pars_commands_into_doc_tree()

  local doctree = ParseFile('./t/example_with_doc.vim')

  luaunit.assertEquals(#doctree, 2)
  luaunit.assertEquals(doctree[1].identifiers[1], ':Command {args}')
  luaunit.assertEquals(doctree[1].text, {'Description of multiple lines, however wide.'})
  luaunit.assertEquals(doctree[1].type, "COMMAND")

  luaunit.assertEquals(doctree[2].identifiers[1], ':Command2 {args}')
  luaunit.assertEquals(doctree[2].identifiers[2], ':Command2! {args}')
  luaunit.assertEquals(doctree[2].text, {'Description of multiple lines, however wide.'})
  luaunit.assertEquals(doctree[2].type, "COMMAND")
end

function Test_should_respect_complicated_text_formatting()

  local doctree = ParseFile('./t/example_with_complex_doc.vim')

  luaunit.assertEquals(#doctree, 1)
  luaunit.assertEquals(doctree[1].identifiers[1], ':Searchalot {searches}')
  luaunit.assertEquals(doctree[1].text[1], 'Run a search through all files in the current working directory. This works similar to running `grep {searches} *`. For example:')
  luaunit.assertEquals(doctree[1].text[2],'`:Sal "prefix" | "specific thing"`')
  luaunit.assertEquals(doctree[1].text[3],'This will first search for the prefix, and then run a search for "specific thing" on all matches of the first search. Results are opend in the quickfix window.')
end

function Test_should_support_variables()

  local doctree = ParseFile('./t/example_with_globals_and_functions.vim')

  luaunit.assertEquals(#doctree, 2)
  luaunit.assertEquals(doctree[1].identifiers[1], 'g:global_var')
  luaunit.assertEquals(doctree[1].text[1], 'Description of variable')
  luaunit.assertEquals(doctree[1].type, 'VARIABLE')

  luaunit.assertEquals(doctree[2].identifiers[1], 'MyFunction()')
  luaunit.assertEquals(doctree[2].text[1], 'Description of function')
  luaunit.assertEquals(doctree[2].type, 'FUNCTION')
end

