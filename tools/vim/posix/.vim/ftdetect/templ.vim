vim9script
# Vim's runtime has no templ filetype; *.templ would otherwise be undetected.
autocmd BufNewFile,BufRead *.templ setfiletype templ
