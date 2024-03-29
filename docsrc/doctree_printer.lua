
local function insertAll(tbl, items)
  for _, value in ipairs( items ) do
    tbl[#tbl+1] = value
  end
end

local function insertAllForKey(table, key, valuesToAdd)
    local newValues = {}
    if table[key] ~= nil then
      newValues = table[key]
    end
    insertAll(newValues, valuesToAdd)
    table[key] = newValues
end

function DocTreeToLines(docTree)
  local textIndent = string.rep(" ", 28) -- 29 for the indent - 1 for the concat
  local linkIndent = string.rep(" ", 44)

  local mappedLines = {}

  local lines = {}
  for _, block in pairs(docTree) do

    -- print links
    for _, command in pairs(block.identifiers) do
      local pureComandName = string.gsub(string.sub(command, 1), "%s.*$", "")
      lines[#lines+1] = linkIndent .. "searchalot-" .. pureComandName
    end

    -- print identifiers with arguments
    for _, command in pairs(block.identifiers) do
      lines[#lines+1] = command
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
    if #lines > 0 and #lines[#lines] < 28 then
      local lenghtOfLastLine = #lines[#lines]
      local lastLine = table.remove(lines, #lines)
      line = lastLine .. string.rep(" ", 28 - lenghtOfLastLine) -- 29 for the indent - 1 for the concat
    else
      line = textIndent
    end

    for i = 1, #block.text do
      for token in string.gmatch(block.text[i],'%S+') do
        local newline = line .. " " .. token
        if #newline <= 78 then
          line = newline
        else
          lines[#lines+1] = line
          line = textIndent .. " " .. token
        end
      end
    end

    lines[#lines+1] = line
    lines[#lines+1] = "" -- empty line to separate blocks

    insertAllForKey(mappedLines, block.type, lines)
    lines = {}

  end
  return mappedLines
end

