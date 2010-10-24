" markdown filetype file
if exists("did\_load\_filetypes")
  finish
endif

autocmd BufNewFile,BufRead *.csv setf csv

augroup markdown
  au! BufRead,BufNewFile *.mkd   setfiletype mkd
augroup END
