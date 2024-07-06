let s:parsedArgsGroupList = []
let s:parsedArgsGroup = []
let s:inputArgChars = []
let s:currentParsedWord = []
let s:inQuote = ""

fu! s:init(argString)
  let s:parsedArgsGroupList = []
  let s:parsedArgsGroup = []
  let s:inputArgChars = split(a:argString, '\zs')
  let s:currentParsedWord = []
  let s:inQuote = ""
endfu

fu! sal#argparse#SplitArgs(argString)
  call s:init(a:argString)

  let index = 0
  while index < len(s:inputArgChars)
    let currentChar = s:inputArgChars[index]

    " Inside quotes is treated as a literal string. So escape all regex related characters
    if s:hasQuoteOpen()
      if currentChar == '\'
        call s:addCharToWord(currentChar)
        " Check if the next char is the same as the currently opened quote.
        " Which would be an escaped closing quote and should be treaded like a
        " normal char.
        let nextChar = s:inputArgChars[index+1]
        if s:isTypeOfQuote(nextChar) && s:isClosingOfOpenedQuote(nextChar)
          " It IS an escaped closer. Add it directly and skip to the char
          " after that.
          let index = index + 1
          call s:addCharToWord(s:inputArgChars[index])
        else
          " literal backslash. Escape like one of the regex characters below
          call s:addCharToWord('\')
        endif

      " any regex chars are escaped, similar to sal#utils#escapeForGNURegexp
      elseif match(currentChar, '[.$*^?\[\]()]') != -1
          call s:addCharToWord('\')
          call s:addCharToWord(currentChar)

      " QUOTE
      elseif s:isTypeOfQuote(currentChar)
          if s:isClosingOfOpenedQuote(currentChar) " this is the closing char
            call s:closeQuote()
          else " not the one we have opened, treat as simple character to parse
            call s:addCharToWord(currentChar)
          endif
      else

        " REGULAR CHAR
        " notice space is treated like a regular char here
        call s:addCharToWord(currentChar)
      endif
    else
      if currentChar == '\'
        " We aren't in quotes, and the next characters is escaped, so skip to
        " the next character (which is escaped), and take it as is.
        let index = index + 1
        call s:addCharToWord(s:inputArgChars[index])

        " SPACE
      elseif currentChar == " "
        call s:endWord() " space but not quoted; end the word

        " QUOTE
      elseif s:isTypeOfQuote(currentChar)
        " not in a quote yet, so this must be an opening quote
        call s:openQuote(currentChar)

      elseif currentChar == "|"
        call s:endGroup()
      else

        " REGULAR CHAR
        call s:addCharToWord(currentChar)
      endif
    endif

    " ESCAPED

    let index = index + 1
  endwhile

  call s:endGroup()
  call sal#log#debug("parsed args:", s:parsedArgsGroupList)
  return s:parsedArgsGroupList
endfunction

fu! s:isTypeOfQuote(char)
  return a:char == '"' || a:char == "'"
endfu

fu! s:addCharToWord(char)
  call add(s:currentParsedWord, a:char)
endfu

fu! s:endWord()
  if len(s:currentParsedWord) >= 1
    call add(s:parsedArgsGroup, s:currentParsedWord->join(""))
  endif
  let s:currentParsedWord = []
endfu

fu! s:hasQuoteOpen()
  return s:inQuote != ""
endfu

fu! s:isClosingOfOpenedQuote(char)
  return s:inQuote == a:char
endfu

fu! s:closeQuote()
  let s:inQuote = ""
endfu

fu! s:openQuote(char)
  let s:inQuote = a:char
endfu

fu! s:endGroup()
  call s:endWord()
  call add(s:parsedArgsGroupList, s:parsedArgsGroup)
  let s:parsedArgsGroup = []
endfu

