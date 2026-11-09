vim9script
# Reuse the HTML ftplugin for omni-completion and matchit tag pairs, then switch to Go conventions.

if exists('b:did_ftplugin')
  finish
endif

runtime! ftplugin/html.vim

# `templ fmt` writes gofmt-style tabs, and Go comments are valid both in Go code and component bodies.
setlocal noexpandtab softtabstop=0 shiftwidth=0
setlocal commentstring=//\ %s
setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal formatoptions-=t
setlocal formatprg=templ\ fmt

b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')
  .. ' | setlocal expandtab< softtabstop< shiftwidth< commentstring< comments< formatoptions< formatprg<'
