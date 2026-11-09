vim9script
# html.vim indents tags but not Go braces and go.vim the reverse, so templ needs its own rules.

if exists('b:did_indent')
  finish
endif
b:did_indent = 1

setlocal autoindent nolisp nosmartindent nocindent
&l:indentexpr = expand('<SID>') .. 'TemplIndent()'
setlocal indentkeys=0},0),0],!^F,o,O,0=</,0=case,0=default
b:undo_indent = 'setlocal autoindent< indentexpr< indentkeys< lisp< smartindent< cindent<'

const void_tags = '\%(area\|base\|br\|col\|embed\|hr\|img\|input\|link\|meta\|source\|track\|wbr\)'

# Net indent change from tags opened and closed on one line, so `<p>x</p>` and `<br>` count as zero.
def TagDelta(line: string): number
  var text = line->substitute('"[^"]*"', '""', 'g')->substitute('{[^{}]*}', '', 'g')
  var opened = 0
  var start = 0
  while true
    var tag = text->matchstrpos('<\zs/\=[[:alnum:]-]\+\%([^>]*/>\)\@!', start)
    if tag[1] == -1
      break
    endif
    if tag[0] =~ '^/'
      opened -= 1
    elseif tag[0] !~? '^' .. void_tags .. '$'
      opened += 1
    endif
    start = tag[2]
  endwhile
  return opened > 0 ? 1 : opened < 0 ? -1 : 0
enddef

def TemplIndent(): number
  var prev_lnum = prevnonblank(v:lnum - 1)
  if prev_lnum == 0
    return 0
  endif

  var prev = getline(prev_lnum)
  var current = getline(v:lnum)
  var level = indent(prev_lnum)
  var step = shiftwidth()

  if prev =~ '[{([]\s*$' || prev =~ '^\s*\%(case\>.*\|default\s*\):\s*$'
    level += step
  elseif TagDelta(prev) > 0
    level += step
  elseif prev =~ '^\s*<[[:alnum:]-]\+\%(\s[^>]*\)\=$'
    level += step
  endif

  if current =~ '^\s*\%([})\]]\|</\)'
    level -= step
  elseif current =~ '^\s*\%(case\>\|default\s*:\)'
    level -= step
  endif

  return max([level, 0])
enddef
