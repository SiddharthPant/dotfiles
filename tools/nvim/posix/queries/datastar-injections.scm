;extends

; Only Datastar's own attributes, so a plain data-id="5" stays a string.
(attribute
  (attribute_name) @_name
  (#match? @_name "\\v^data-(attr|bind|class|computed|effect|ignore|ignore-morph|indicator|init|json-signals|on|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|preserve-attr|ref|show|signals|style|text|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition)([:_].*)?$")
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#set! injection.language "javascript"))
