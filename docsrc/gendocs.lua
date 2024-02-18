
-- TODO: 
--  - Respect empty lines?
--  - Repect line breaks by ending vimdoc in 2 spaces
--  - Support for variables and public functions (separate groups)

function ParseFile(filePath)
  local blocks = {}
  local currentBlock = { commands = {}, text = "" }

  local file = io.open(filePath, "r")
  if not file then print(string.format("file %s not found?", filePath)) end

  for line in io.lines(filePath) do
    if line:find("^\"\"\"") ~= nil then
      local docText = string.sub(line, 5)
      if docText:find("^:") ~= nil then
        table.insert(currentBlock["commands"], docText)
      elseif currentBlock['text'] == "" then
        currentBlock["text"] = docText
      else
        currentBlock["text"] = currentBlock["text"] .. " " .. docText
      end
    else
      if #currentBlock["text"] >= 1 then
        table.insert(blocks, currentBlock)
        currentBlock = { commands = {}, text = "" }
      end
    end
  end
  if currentBlock['text'] ~= "" then
    table.insert(blocks, currentBlock)
  end
  return blocks
end


function DocTreeToLines(docTree)
  local textIndent = string.rep(" ", 28) -- 29 for the indent - 1 for the concat
  local linkIndent = string.rep(" ", 49)

  local lines = {}
  for _, block in pairs(docTree) do

    -- print links
    for _, command in pairs(block["commands"]) do
      local pureComandName = string.gsub(string.sub(command, 1), "%s.*$", "")
      table.insert(lines, linkIndent .. "searchalot-" .. pureComandName)
    end

    -- print commands with arguments
    for _, command in pairs(block["commands"]) do
      table.insert(lines, command)
    end

    -- Print command description.
    -- This part takes the text, adds an intent, and wraps it after the max line length.
    --
    -- If the preceding command is shorter than the indent, the command is
    -- placed in the start of the same line as the text. To do this we:
    -- 1. check if the last line (last command) is shorter than the text indent
    -- 2. Remove the last line (last command) from the lines list
    -- 3. Start the new line with the command, then add indent minus the command width
    -- 4. Add the text with indent one word at a time untill the line is to long.
    local line = ""
    local lenghtOfLastLine = #lines[#lines]
    if lenghtOfLastLine < 28 then
      local lastLine = table.remove(lines, #lines)
      line = lastLine .. string.rep(" ", 28 - lenghtOfLastLine) -- 29 for the indent - 1 for the concat
    else
      line = textIndent
    end

    for token in string.gmatch(block["text"],'%S+') do
      local newline = line .. " " .. token
      if #newline <= 78 then
        line = newline
      else
        table.insert(lines, line)
        line = textIndent .. " " .. token
      end
    end

    table.insert(lines, line)
    table.insert(lines, "") -- empty line to separate blocks
  end
  return lines
end

