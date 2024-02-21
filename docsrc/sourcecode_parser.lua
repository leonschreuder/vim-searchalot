
function DocItem()
  return {
    commands = {},
    text = {""},

    addCommand = function(self, commandText)
      table.insert(self.commands, commandText)
    end,

    addText = function(self, text)
      if self.text[#self.text] == "" then
        self.text[#self.text] = text
      else
        self.text[#self.text] = self.text[#self.text] .. " " .. text
      end
    end,

    addTextLineBreak = function(self)
      table.insert(self.text, "")
    end,

    notEmpty = function(self)
      return #self.text >= 1 and self.text[#self.text] ~= ""
    end,

    toString = function(self)
      print("{")
      print("  commands: {")
      for i = 1, #self.commands do
        print("    "..self.commands[i])
      end
      print("  }")
      print("  text: {")
      for i = 1, #self.text do
        print("    '"..self.text[i].."'")
      end
      print("  }")
      print("}")
    end
  }
end

-- TODO: 
--  - Respect empty lines?
--  - Repect line breaks by ending vimdoc in 2 spaces
--  - Support for variables and public functions (separate groups)

function ParseFile(filePath)
  local blocks = {}
  local docItem = DocItem()

  local file = io.open(filePath, "r")
  if not file then print(string.format("file %s not found?", filePath)) end

  for line in io.lines(filePath) do
    if line:find("^\"\"\"") ~= nil then
      local docText = string.sub(line, 5)
      if docText:find("^:") ~= nil then
        docItem:addCommand(docText)
      elseif docText:find("%s%s$") then
        docItem:addText(docText:sub(1, -3))
        docItem:addTextLineBreak()
      else
        docItem:addText(docText)
      end
    else
      if docItem:notEmpty() then
        table.insert(blocks, docItem)
        docItem = DocItem()
      end
    end
  end
  if docItem:notEmpty() then
    table.insert(blocks, docItem)
  end
  return blocks
end

