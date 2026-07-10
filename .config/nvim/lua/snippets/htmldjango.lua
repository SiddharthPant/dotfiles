-- Askama snippets for files assigned the htmldjango filetype.
return {
	{ prefix = "var", description = "Askama expression", body = "{{ ${1:expression} }}" },
	{ prefix = "comment", description = "Askama comment", body = "{# $0 #}" },
	{ prefix = "if", description = "Askama if block", body = { "{% if ${1:condition} %}", "  $0", "{% endif %}" } },
	{
		prefix = "ife",
		description = "Askama if/else block",
		body = { "{% if ${1:condition} %}", "  $2", "{% else %}", "  $0", "{% endif %}" },
	},
	{
		prefix = "for",
		description = "Askama for block",
		body = { "{% for ${1:item} in ${2:items} %}", "  $0", "{% endfor %}" },
	},
	{
		prefix = "fore",
		description = "Askama for/else block",
		body = { "{% for ${1:item} in ${2:items} %}", "  $3", "{% else %}", "  $0", "{% endfor %}" },
	},
	{
		prefix = "match",
		description = "Askama match block",
		body = { "{% match ${1:value} %}", "  {% when ${2:pattern} %}", "    $0", "{% endmatch %}" },
	},
	{
		prefix = "block",
		description = "Askama inheritance block",
		body = { "{% block ${1:name} %}", "  $0", "{% endblock %}" },
	},
	{
		prefix = "macro",
		description = "Askama macro",
		body = { "{% macro ${1:name}(${2:args}) %}", "  $0", "{% endmacro %}" },
	},
	{
		prefix = "filter",
		description = "Askama filter block",
		body = { "{% filter ${1:filter} %}", "  $0", "{% endfilter %}" },
	},
	{ prefix = "let", description = "Askama let binding", body = "{% let ${1:name} = ${2:value} %}" },
	{ prefix = "set", description = "Askama set binding", body = "{% set ${1:name} = ${2:value} %}" },
	{ prefix = "include", description = "Askama include", body = '{% include "${1:path}" %}' },
	{ prefix = "extends", description = "Askama template inheritance", body = '{% extends "${1:path}" %}' },
}
