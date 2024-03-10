local luaunit = require('luaunit')

require('doctree_printer')

function Test_should_convert_doctree_to_lines()
  local doctree = {
    {
      identifiers = { ":Command {args}", ":Cmd {args}"},
      text =  { "Run a search through all files in the current working directory." },
      type = "COMMAND",
    },
    {
      identifiers = { ":Command2 {args}"},
      text =  { "Same as |:Sal| but open the result in the location list." },
      type = "COMMAND",
    },
  }

  local result = DocTreeToLines(doctree)

  local commandLines = result["COMMAND"]
  luaunit.assertEquals(commandLines[1], "                                            searchalot-:Command")
  luaunit.assertEquals(commandLines[2], "                                            searchalot-:Cmd")
  luaunit.assertEquals(commandLines[3], ":Command {args}")
  luaunit.assertEquals(commandLines[4], ":Cmd {args}                  Run a search through all files in the current")
  luaunit.assertEquals(commandLines[5], "                             working directory.")
  luaunit.assertEquals(commandLines[6], "")
  luaunit.assertEquals(commandLines[7], "                                            searchalot-:Command2")
  luaunit.assertEquals(commandLines[8], ":Command2 {args}             Same as |:Sal| but open the result in the")
  luaunit.assertEquals(commandLines[9], "                             location list.")
end

