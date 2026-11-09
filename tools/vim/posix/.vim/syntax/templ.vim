vim9script
# templ files are Go with HTML component bodies: Go outside, HTML inside `templ Name() { ... }`.

if exists('b:current_syntax')
  finish
endif

runtime! syntax/go.vim
unlet! b:current_syntax
# html.vim's bold/italic/link rendering regions would hide templ expressions nested inside them.
var had_no_rendering = exists('g:html_no_rendering')
g:html_no_rendering = 1
syntax include @templHtml syntax/html.vim
unlet! b:current_syntax
if !had_no_rendering
  unlet g:html_no_rendering
endif

syntax case match

syntax match templKeyword /^\%(templ\|css\|script\)\>/

# The body starts at the header's trailing `{` so the header itself keeps Go highlighting.
syntax cluster templBodyItems contains=templExpr,templStatement,templCase,templCall,templComment
syntax region templBody matchgroup=templBrace start=/\%(^templ\>.*\)\@<={\s*$/ end=/^}/ keepend
      \ contains=@templHtml,@templBodyItems

# Go expressions such as `{ name }` and `{ attrs... }`; nests for composite literals.
syntax region templExpr matchgroup=templBrace start=/{/ end=/}/ contained containedin=htmlTag
      \ contains=TOP,templExpr
# Defined after html.vim so it beats htmlValue, which would otherwise swallow the `{` of `class={ cls }`.
syntax match templAttrEquals /=\s*\ze{/ contained containedin=htmlTag nextgroup=templExpr

# Blocks of if/for/switch and `@Layout() { ... }` children hold markup, and nest so each `}` closes its own block.
syntax region templBlock matchgroup=templBrace start=/{\s*$/ end=/^\s*\zs}/ contained
      \ contains=@templHtml,@templBodyItems nextgroup=templElse skipwhite
syntax match templStatement /^\s*\zs\%(if\|for\|switch\)\>.\{-}\ze{\s*$/ contained contains=TOP nextgroup=templBlock
syntax match templElse /else\>.\{-}\ze{\s*$/ contained contains=TOP nextgroup=templBlock
syntax match templCase /^\s*\zs\%(case\>.*\|default\s*\):\s*$/ contained contains=TOP
syntax match templCall /@\h[[:alnum:]_.]*/ contained nextgroup=templCallArgs,templBlock skipwhite
syntax region templCallArgs matchgroup=templCall start=/(/ end=/)/ contained contains=TOP nextgroup=templBlock skipwhite
syntax match templComment /^\s*\zs\/\/.*/ contained contains=@goCommentGroup,@Spell
syntax region templComment start=/^\s*\zs\/\*/ end=/\*\// contained contains=@goCommentGroup,@Spell

# Component bodies can be long; html.vim's sync rules don't know about them.
syntax sync fromstart

highlight default link templKeyword Keyword
highlight default link templBrace Delimiter
highlight default link templAttrEquals htmlTag
highlight default link templStatement Conditional
highlight default link templElse Conditional
highlight default link templCase Label
highlight default link templCall Function
highlight default link templComment Comment

b:current_syntax = 'templ'
