local luaunit = require('luaunit')

require('docsrc.gendocs')

function Test_should_scan_file_into_doc_tree()

  local doctree = ParseFile('./docsrc/t/example_with_doc.vim')

  luaunit.assertEquals(#doctree, 2)
  luaunit.assertEquals(doctree[1]['commands'][1], ':Command {args}')
  luaunit.assertEquals(doctree[1]['text'], 'Description of multiple lines, however wide.')

  luaunit.assertEquals(doctree[2]['commands'][1], ':Command2 {args}')
  luaunit.assertEquals(doctree[2]['commands'][2], ':Command2! {args}')
  luaunit.assertEquals(doctree[2]['text'], 'Description of multiple lines, however wide.')
end


function Test_should_convert_doctree_to_lines()
  local doctree = {
    {
      commands = { ":Command {args}", ":Cmd {args}"},
      text =  "Run a search through all files in the current working directory."
    },
    {
      commands = { ":Command2 {args}"},
      text =  "Same as |:Sal| but open the result in the location list."
    },
  }

  local result = DocTreeToLines(doctree)

  luaunit.assertEquals(result[1], "                                                 searchalot-:Command")
  luaunit.assertEquals(result[2], "                                                 searchalot-:Cmd")
  luaunit.assertEquals(result[3], ":Command {args}")
  luaunit.assertEquals(result[4], ":Cmd {args}                  Run a search through all files in the current")
  luaunit.assertEquals(result[5], "                             working directory.")
  luaunit.assertEquals(result[6], "")
  luaunit.assertEquals(result[7], "                                                 searchalot-:Command2")
  luaunit.assertEquals(result[8], ":Command2 {args}             Same as |:Sal| but open the result in the")
  luaunit.assertEquals(result[9], "                             location list.")
end

os.exit(luaunit.LuaUnit.run())
