local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local i = ls.insert_node
local s = ls.snippet

return {
	s(
		{ trig = "var", name = "Askama expression" },
		fmta("{{ <expression> }}", {
			expression = i(1, "expression"),
		})
	),
	s(
		{ trig = "comment", name = "Askama comment" },
		fmta("{# <comment> #}", {
			comment = i(0),
		})
	),
	s(
		{ trig = "if", name = "Askama if block" },
		fmta(
			[[
{% if <condition> %}
  <body>
{% endif %}
]],
			{
				condition = i(1, "condition"),
				body = i(0),
			}
		)
	),
	s(
		{ trig = "ife", name = "Askama if/else block" },
		fmta(
			[[
{% if <condition> %}
  <if_body>
{% else %}
  <else_body>
{% endif %}
]],
			{
				condition = i(1, "condition"),
				if_body = i(2),
				else_body = i(0),
			}
		)
	),
	s(
		{ trig = "for", name = "Askama for block" },
		fmta(
			[[
{% for <item> in <items> %}
  <body>
{% endfor %}
]],
			{
				item = i(1, "item"),
				items = i(2, "items"),
				body = i(0),
			}
		)
	),
	s(
		{ trig = "fore", name = "Askama for/else block" },
		fmta(
			[[
{% for <item> in <items> %}
  <for_body>
{% else %}
  <else_body>
{% endfor %}
]],
			{
				item = i(1, "item"),
				items = i(2, "items"),
				for_body = i(3),
				else_body = i(0),
			}
		)
	),
	s(
		{ trig = "match", name = "Askama match block" },
		fmta(
			[[
{% match <value> %}
  {% when <pattern> %}
    <body>
{% endmatch %}
]],
			{
				value = i(1, "value"),
				pattern = i(2, "pattern"),
				body = i(0),
			}
		)
	),
	s(
		{ trig = "block", name = "Askama inheritance block" },
		fmta(
			[[
{% block <name> %}
  <body>
{% endblock %}
]],
			{
				name = i(1, "name"),
				body = i(0),
			}
		)
	),
	s(
		{ trig = "macro", name = "Askama macro" },
		fmta(
			[[
{% macro <name>(<args>) %}
  <body>
{% endmacro %}
]],
			{
				name = i(1, "name"),
				args = i(2, "args"),
				body = i(0),
			}
		)
	),
	s(
		{ trig = "filter", name = "Askama filter block" },
		fmta(
			[[
{% filter <filter> %}
  <body>
{% endfilter %}
]],
			{
				filter = i(1, "filter"),
				body = i(0),
			}
		)
	),
	s(
		{ trig = "let", name = "Askama let binding" },
		fmta("{% let <name> = <value> %}", {
			name = i(1, "name"),
			value = i(2, "value"),
		})
	),
	s(
		{ trig = "set", name = "Askama set binding" },
		fmta("{% set <name> = <value> %}", {
			name = i(1, "name"),
			value = i(2, "value"),
		})
	),
	s(
		{ trig = "include", name = "Askama include" },
		fmta('{% include "<path>" %}', {
			path = i(1, "path"),
		})
	),
	s(
		{ trig = "extends", name = "Askama template inheritance" },
		fmta('{% extends "<path>" %}', {
			path = i(1, "path"),
		})
	),
}
