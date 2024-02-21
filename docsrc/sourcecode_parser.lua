
function DocItem()
  return {
    identifiers = {},
    text = {""},
    type = "",

    addIdentifier = function(self, commandText)
      table.insert(self.identifiers, commandText)
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
      print("type:"..self.type)
      print("  identifiers: {")
      for i = 1, #self.identifiers do
        print("    "..self.identifiers[i])
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
        docItem:addIdentifier(docText)
        docItem.type = "COMMAND"
      elseif docText:find("^g:") ~= nil then
        docItem:addIdentifier(docText)
        docItem.type = "VARIABLE"
      elseif docText:find("%(%)$") ~= nil then
        docItem:addIdentifier(docText)
        docItem.type = "FUNCTION"
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

