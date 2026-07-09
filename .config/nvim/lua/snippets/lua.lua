-- Lua snippets {{{
return {
	req = 'local ${1:name} = require("${2:module}")',
	fn = "local function ${1:name}(${2:args})\n\t${0}\nend",
	map = 'map("${1:n}", "${2:lhs}", ${3:rhs}, { desc = "${4:desc}" })',
}
-- }}}

-- vim: foldmethod=marker foldlevel=0
