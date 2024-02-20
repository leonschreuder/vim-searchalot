
""" :Searchalot {searches}
""" 
""" Run a search through all files in the current working directory. This
""" works similar to running `grep {searches} *`. For example:  
""" `:Sal "prefix" | "specific thing"`  
""" This will first search for the prefix, and then run a search for "specific
""" thing" on all matches of the first search. Results are opend in the
""" quickfix window.
