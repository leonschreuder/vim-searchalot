
vim-searchalot
================================================================================

The night in the shiny armor to help you find things fast.

vim-searchalot tries to get the fastest searcher available on your machine, and
use that to find things and put them into the quickfix window. After that it
will also highlight the searches for you.

<!-- Example gif -->

It is built to help searching large log files and analyse them quickly. See
also [vim-chunk](https://github.com/leonschreuder/vim-chunk) to read only parts
of large log files for fast and eficient log searching.

Getting started
------------------------------------------------------------

1. Install the plugin using your favorite plugin manager.
2. Now perform a search. Like this for example:
  - change (cd) into a sourcecode directory you want to search and open vim
  - Enter the command `:Searcha "my-search"`
  - Open the quickfix window (for example calling the command `:copen`)
  - You now see all the matches to your search, highlighting each match
  - Press `<enter>` to open the file with the match. The match is also
    highlighted in the file.
3. Setup mappings
  This plugin does not automatically set any mappings as that might mess up
  your current mappings. But here are some I suggest using. Copy them to your
  vimrc and change the mappings to fit your needs if you want.

```
    " quickly search the word under the cursor using vim-searchalot
    nnoremap <leader>/ :call SearchalotCurrentWord()<CR>
    " quickly search the selected word using vim-searchalot
    vnoremap <leader>/ :call SearchalotSelection()<CR>
```

How-tos
--------------------------------------------------------------------------------

### How do I search for a word, how are spaces handled?

Spaces are handled like the linux shell: Every word separated by a space is
one element and one search. Escaping the\ space, or putting words "in quotes"
('single' or "double") treats them as a combined string.

```
  :Searcha search1 search2
  :Searcha search\ 3 "search 4" 'search 5'
```

### Can I use regexes?

Yes. Searches are simply handed to the search tool, so as long as you use
standard regex stuff, you'll be fine with any tool. If you want to do
non-standard stuff (like lookahead, lookbehind, etc), you might need to look
in the documentation of the tool you are using. Notice that the highlighting
uses vim-internal regexes, which might behave differently.
```
  :Searcha "[eE]llo\sthere!"
```

### How can I string multiple searches together?

If you want to search for a stirng and then search again in those matches, you
would do something like this in the shell: `grep 'prefix' | grep thing`
Seachalot supports this by using the pipe '|' character. For example:
```
  :Searcha "prefix" | "some sub-match"
```

Alternatives
------------------------------------------------------------

I didn't really search around for other tools and just started building my own
(like a dumbass). The thing that this plugin is mostly lacking right now, is
the lack of customisation of the searches. But that doesn't fit my usecase and
would be added bloat, so I probably won't add that. The strenghts of this
plugin however are the built-in highlighing and combining multiple piped
searches together. Check these other plugins out to see if they might fit your
needs better:

[ack.vim](https://github.com/mileszs/ack.vim)
Uses Ack per default but can be configured to use ripgrep for example. It is
very similar to this plugin without the highlighting or chained searches.

[fzf.vim](https://github.com/junegunn/fzf.vim)
Allows you to search using several tools, using fuzzy searching, and opens a
pretty popup window that is easy to navigate. This is awasome if you want to
find stuff in code, less so if you want to analyse logs for events etc.

[vim-esearch](https://github.com/eugen0329/vim-esearch)
More search and replace based I think.

If you know any more alternatives I'd be happy to add them here.
