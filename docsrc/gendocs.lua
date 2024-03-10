
require('sourcecode_parser')
require('doctree_printer')
require('template_printer')

local filePath = "../plugin/searchalot.vim"
local docTree = ParseFile(filePath)
local mappedLines = DocTreeToLines(docTree)
ApplyTemplate('./searchalot_template.txt', "../doc/searchalot.txt", mappedLines)
