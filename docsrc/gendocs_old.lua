
-- local file = io.open(filePath, "r")
-- if not file then print(string.format("file %s not found?", filePath)) end


require('docsrc.gendocs')

local filePath = "plugin/searchalot.vim"
local docTree = ParseFile(filePath)
local lines = DocTreeToLines(docTree)

for _, line in pairs(lines) do
  print(line)
end

-- local blocks = {}
-- local currentBlock = { commands = {}, text = "" }
-- for line in io.lines(filePath) do
--   if line:find("^\"\"\"") ~= nil then
--     local docText = string.sub(line, 5)
--     -- print(string.format("> %s", docText))
--     if docText:find("^:") ~= nil then
--       -- print("cmds:")
--       table.insert(currentBlock["commands"], docText)
--       -- print(currentBlock["commands"])
--     else
--       currentBlock["text"] = string.format("%s %s", currentBlock["text"], docText)
--       -- print(currentBlock["text"])
--     end
--   else
--     if #currentBlock["text"] >= 1 then
--       table.insert(blocks, currentBlock)
--       -- print("endblock")
--       currentBlock = { commands = {}, text = "" }
--     end
--   end
-- end

-- for _, block in pairs(blocks) do
--   print("{")
--   if block["commands"] ~= nil then
--     print("commands:")
--     for _, item in pairs(block["commands"]) do
--       print(item)
--     end
--   end
--   print("text:")
--   -- print(block["text"])
--   for token in string.gmatch(block["text"],'%w+') do
--     print (token)
--   end

--   -- for key, currentBlock in pairs(block) do
--   --   if key == "commands" then
--   --     for _, item in pairs(currentBlock) do
--   --       print(item)
--   --     end
--   --   else
--   --     print(currentBlock)
--   --   end
--   -- end
--   print("}")
-- end
