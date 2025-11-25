

" sort of like a constructor for the class-like object Input
fu! sal#argparse#Input(argString)
  let Input = {
        \   "currentCharIndex": -1,
        \   "inputArgChars": [],
        \}

  fu! Input.popChar() dict
    let self.currentCharIndex = self.currentCharIndex + 1
    return self.inputArgChars[self.currentCharIndex]
  endfu

  fu! Input.hasNextChar() dict
    return (self.currentCharIndex + 1) < len(self.inputArgChars)
  endfu

  fu! Input.peekNextChar() dict
    return self.inputArgChars[self.currentCharIndex + 1]
  endfu

  fu! Input.peekPreviousChar() dict
    return self.inputArgChars[self.currentCharIndex - 1]
  endfu

  fu! Input.peekCharDelata(delta) dict
    return self.inputArgChars[self.currentCharIndex + delta]
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
    let currentChar = input.popChar()

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
          call parseResult.addCharToWord(input.popChar())
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
      " NOT IN QUOTES

      if currentChar == '\' && input.peekNextChar() == '\'
        " You've encountered a wild '\\'
        " This is basically just passed it to the grep command, but we have to
        " handle it explicitly because of the escaping of spaces (below).
        " Simply add both slashes to the word so they don't get interprated
        " separately in case they are followed by a search-seaparating-space.
        call parseResult.addCharToWord(currentChar)
        call parseResult.addCharToWord(input.popChar())

      elseif currentChar == '\' && input.peekNextChar() == ' '
        " You've encountered a wild '\ '
        " An escaped space is used to destinguish between separate, space
        " separated search querries. This is just like in a grep-like command
        " from the shell, but as we pass the searches to the grep command
        " pre-grouped, we don't need to pass the escape characters. But we do
        " need it here to provide the same standarad separation convention.
        " Just skip the slash, and add the pace to the word, as opposed to
        " ending the word like we normally would.
        call parseResult.addCharToWord(input.popChar())


      elseif currentChar == " "
        " You've encountered a wild ' '
        " Space ends the search group/word
        call parseResult.endWord()

      elseif s:isTypeOfQuote(currentChar)
        " You've encountered a wild '"'
        " we weren't in a quote yet, so this must be an opening quote
        call parseResult.openQuote(currentChar)

      elseif currentChar == "|" && parseResult.isNotInGroup() && input.peekNextChar() == " "
        " You've encountered a wild ' | '
        " A pipe surronded by spaces ends a group for stringing multiple commands together
        call parseResult.endGroup()
      else
        " REGULAR CHAR
        call parseResult.addCharToWord(currentChar)
      endif
    endif

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
