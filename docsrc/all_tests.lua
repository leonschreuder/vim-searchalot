require('doctree_printer_test')
require('sourcecode_parser_test')
require('template_printer_test')

local lu = require("luaunit")
os.exit(lu.LuaUnit.run())
