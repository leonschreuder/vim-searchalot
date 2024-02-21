local luaunit = require('luaunit')

require('doctree_printer')

function Test_should_convert_doctree_to_lines()
  local doctree = {
    {
      identifiers = { ":Command {args}", ":Cmd {args}"},
      text =  { "Run a search through all files in the current working directory." }
    },
    {
      identifiers = { ":Command2 {args}"},
      text =  { "Same as |:Sal| but open the result in the location list." }
    },
  }

  local result = DocTreeToLines(doctree)


  luaunit.assertEquals(result[1], "                                            searchalot-:Command")
  luaunit.assertEquals(result[2], "                                            searchalot-:Cmd")
  luaunit.assertEquals(result[3], ":Command {args}")
  luaunit.assertEquals(result[4], ":Cmd {args}                  Run a search through all files in the current")
  luaunit.assertEquals(result[5], "                             working directory.")
  luaunit.assertEquals(result[6], "")
  luaunit.assertEquals(result[7], "                                            searchalot-:Command2")
  luaunit.assertEquals(result[8], ":Command2 {args}             Same as |:Sal| but open the result in the")
  luaunit.assertEquals(result[9], "                             location list.")
end

