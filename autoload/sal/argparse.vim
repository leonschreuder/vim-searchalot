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

function! sal#argparse#SplitArgs(argString)
  call s:init(a:argString)

	let index = 0
  while index < len(s:inputArgChars)
    let currentChar = s:inputArgChars[index]

    " ESCAPED
    if currentChar == "\\"
      " The next characters is escaped, so skip to the next character, and
      " take it as is. To support stuff like \n it should be added here
      let index = index + 1
      call s:addCharToWord(s:inputArgChars[index])

    " SPACE
    elseif currentChar == " "
      if s:hasQuoteOpen()  " space but we're in a quote; ignore the space and continue
        call s:addCharToWord(currentChar)
      else
        call s:endWord() " space but not quoted; end the word
      endif

    " QUOTE
    elseif s:isQuote(currentChar)
      if s:hasQuoteOpen()
        if s:isClosingQuote(currentChar) " this is the closing char
          call s:closeQuote()
        else " not the one we have opened, treat as simple character to parse
          call s:addCharToWord(currentChar)
        endif
      else
        " not in a quote yet, so this is an opening quote
        call s:openQuote(currentChar)
      endif

    elseif currentChar == "|"
      call s:endGroup()
    else

      " REGULAR CHAR
      call s:addCharToWord(currentChar)
    endif

    let index = index + 1
  endwhile

  call s:endGroup()
  return s:parsedArgsGroupList
endfunction

fu! s:isQuote(char)
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

fu! s:isClosingQuote(char)
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

