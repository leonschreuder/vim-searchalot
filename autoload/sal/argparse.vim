

" sort of like a constructor for the class-like object Input
fu! sal#argparse#Input(argString)
  let Input = {
        \   "currentCharIndex": -1,
        \   "inputArgChars": [],
        \}

  fu! Input.hasNextChar() dict
    return (self.currentCharIndex + 1) < len(self.inputArgChars)
  endfu

  fu! Input.popNextChar() dict
    let self.currentCharIndex = self.currentCharIndex + 1
    return self.inputArgChars[self.currentCharIndex]
  endfu

  fu! Input.peekNextChar() dict
    return self.inputArgChars[self.currentCharIndex + 1]
  endfu

  fu! Input.moveToNextChar() dict
    let self.currentCharIndex = self.currentCharIndex + 1
  endfu

  let Input.inputArgChars = split(a:argString, '\zs')
  return Input
endfu

" sort of like a constructor for the class-like object ParseResult
fu! sal#argparse#ParseResult()
  let ParseResult = {
        \   "currentParsedWord": [],
        \   "parsedArgsGroup": [],
        \   "parsedArgsGroupList": [],
        \   "inQuote": ""
        \}

  fu! ParseResult.addCharToWord(char) dict
    let self.currentParsedWord = add(self.currentParsedWord, a:char)
  endfu

  fu! ParseResult.endWord()
    if len(self.currentParsedWord) >= 1
      call add(self.parsedArgsGroup, self.currentParsedWord->join(""))
    endif
    let self.currentParsedWord = []
  endfu

  fu! ParseResult.endGroup()
    call self.endWord()
    call add(self.parsedArgsGroupList, self.parsedArgsGroup)
    let self.parsedArgsGroup = []
  endfu


  fu! ParseResult.isInQuote()
    return self.inQuote != ""
  endfu

  fu! ParseResult.closeQuote()
    let self.inQuote = ""
  endfu

  fu! ParseResult.openQuote(char)
    let self.inQuote = a:char
  endfu

  fu! ParseResult.isNotInGroup()
    return len(self.currentParsedWord) == 0
  endfu

  fu! ParseResult.isClosingQuote(char)
    return self.inQuote == a:char
  endfu

  return ParseResult
endfu



fu! sal#argparse#SplitArgs(argString)
  let inputArgChars = split(a:argString, '\zs')
  let parseResult = sal#argparse#ParseResult()
  let input = sal#argparse#Input(a:argString)

  call sal#log#debug("input:", a:argString)

  while input.hasNextChar()
    let currentChar = input.popNextChar()

    " Inside quotes is treated as a literal string. So escape all regex related characters
    if parseResult.isInQuote()
      if currentChar == '\'
        call parseResult.addCharToWord(currentChar)
        " Check if the next char is the same as the currently opened quote.
        " Which would be an escaped closing quote and should be treaded like a
        " normal char.
        let nextChar = input.peekNextChar()
        if s:isTypeOfQuote(nextChar) && parseResult.inQuote == nextChar
          " It IS an escaped closer. Add it directly and skip to the char
          " after that.
          call parseResult.addCharToWord(input.popNextChar())
        else
          " literal backslash. Escape like one of the regex characters below
          call parseResult.addCharToWord('\')
        endif

      " any regex chars are escaped, similar to sal#utils#escapeForGNURegexp
      elseif s:isRegexChar(currentChar)
          call parseResult.addCharToWord('\')
          call parseResult.addCharToWord(currentChar)

      " QUOTE
      elseif s:isTypeOfQuote(currentChar)
          if parseResult.isClosingQuote(currentChar) " this is the closing char
            call parseResult.closeQuote()
          else " not the one we have opened, treat as simple character to parse
            call parseResult.addCharToWord(currentChar)
          endif
      else

        " REGULAR CHAR
        " notice space is treated like a regular char here
        call parseResult.addCharToWord(currentChar)
      endif
    else
      if currentChar == '\'
        " We aren't in quotes, and the next characters is escaped, so skip to
        " the next character (which is escaped), and take it as is.
        call parseResult.addCharToWord(input.popNextChar())

        " SPACE
      elseif currentChar == " "
        call parseResult.endWord()

        " QUOTE
      elseif s:isTypeOfQuote(currentChar)
        " not in a quote yet, so this must be an opening quote
        call parseResult.openQuote(currentChar)

      elseif currentChar == "|" && parseResult.isNotInGroup() && input.peekNextChar() == " "
        call parseResult.endGroup()
      else

        " REGULAR CHAR
        call parseResult.addCharToWord(currentChar)
      endif
    endif

    " ESCAPED

  endwhile

  call parseResult.endGroup()
  call sal#log#debug("parsed args:", parseResult.parsedArgsGroupList)

  " return s:parsedArgsGroupList
  return parseResult.parsedArgsGroupList
endfunction

fu! s:isTypeOfQuote(char)
  return a:char == '"' || a:char == "'"
endfu

fu! s:isRegexChar(char)
  return match(a:char, '[.$*^?\[\]()]') != -1
endfu
