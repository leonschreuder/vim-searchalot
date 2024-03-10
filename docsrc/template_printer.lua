
function ApplyTemplate(templatePath, outFile, keysWithLines)
  local inputFile = io.open(templatePath, "r")
  if not inputFile then print(string.format("inputFile %s not found?", templatePath)) end

  local outFilehandle = io.open(outFile, "w")
  if not outFilehandle then error(string.format("outputFile %s not found?", outFile)) end

  for line in io.lines(templatePath) do
    if line:find("^{{") ~= nil then
      local name = line:match("{{(%a+)}}")
      local keyLines = keysWithLines[name]
      if keyLines == nil then
        error(string.format("Could not find key '%s' in the provided keysWithLines", name))
      end
      for _, keyLine in pairs(keyLines) do
        outFilehandle:write(keyLine.."\n")
      end
    else
      outFilehandle:write(line.."\n")
    end
  end
  outFilehandle:close()
end
