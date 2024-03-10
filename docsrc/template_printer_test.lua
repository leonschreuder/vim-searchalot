local luaunit = require('luaunit')

require('template_printer')

function Test_should_pars_commands_into_doc_tree2()
  local keysWithLines = {
    FIRST = {
      "first line1",
      "first line2"
    },
    SECOND = {
      "second line1",
      "second line2"
    },
  }

  local outFile = os.tmpname()
  ApplyTemplate("./t/template.txt", outFile, keysWithLines)

  local outputFileText = io.open(outFile):read("*a")
  luaunit.assertEquals(outputFileText, [[First:
first line1
first line2

Second:
second line1
second line2
]])
end
