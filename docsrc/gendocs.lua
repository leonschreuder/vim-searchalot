
require('sourcecode_parser')
require('doctree_printer')

local filePath = "../plugin/searchalot.vim"
local docTree = ParseFile(filePath)
local lines = DocTreeToLines(docTree)

for _, line in pairs(lines) do
  print(line)
end
