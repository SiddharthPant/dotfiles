-- Python snippets {{{
return {
	-- Functions / classes {{{
	main = 'if __name__ == "__main__":\n\t${0}',
	fn = "def ${1:name}(${2:args}) -> ${3:None}:\n\t${0}",
	afn = "async def ${1:name}(${2:args}) -> ${3:None}:\n\t${0}",
	cls = "class ${1:Name}:\n\tdef __init__(self${2:, args}) -> None:\n\t\t${0}",
	datacls = "from dataclasses import dataclass\n\n@dataclass\nclass ${1:Name}:\n\t${2:field}: ${3:str}\n\t${0}",
	prop = "@property\nndef ${1:name}(self) -> ${2:str}:\n\t${0}",
	static = "@staticmethod\ndef ${1:name}(${2:args}) -> ${3:None}:\n\t${0}",
	classmethod = "@classmethod\ndef ${1:name}(cls${2:, args}) -> ${3:None}:\n\t${0}",
	-- }}}

	-- Control flow {{{
	["for"] = "for ${1:item} in ${2:items}:\n\t${0}",
	fore = "for ${1:i}, ${2:item} in enumerate(${3:items}):\n\t${0}",
	["with"] = "with ${1:expr} as ${2:f}:\n\t${0}",
	open = "with open(${1:path}) as ${2:f}:\n\t${0}",
	try = "try:\n\t${1}\nexcept ${2:Exception} as ${3:e}:\n\t${0}",
	["if"] = "if ${1:cond}:\n\t${0}",
	ife = "if ${1:cond}:\n\t${2}\nelse:\n\t${0}",
	-- }}}

	-- Comprehensions / lambda {{{
	lc = "[${1:x} for ${1:x} in ${2:items}${3: if ${4:cond}}]",
	dc = "{${1:k}: ${2:v} for ${1:k}, ${2:v} in ${3:items}${4: if ${5:cond}} }",
	lam = "lambda ${1:x}: ${2:x}",
	-- }}}

	-- Imports / IO {{{
	imp = "import ${1:module}",
	imf = "from ${1:module} import ${2:name}",
	pr = "print(${1})",
	log = 'logger.${1:info}("${2:msg}")',
	raise = 'raise ${1:ValueError}("${2:msg}")',
	assert = "assert ${1:cond}, ${2:msg}",
	-- }}}

	-- Testing {{{
	test = "def test_${1:name}() -> None:\n\t${0}",
	fixt = "@pytest.fixture\ndef ${1:name}():\n\t${0}",
	param = '@pytest.mark.parametrize("${1:arg}", [${2:cases}])\ndef test_${3:name}(${1:arg}) -> None:\n\t${0}',
	-- }}}

	-- Typing / tooling {{{
	type = "${1:name}: ${2:str} = ${3:value}",
	typed = "from typing import ${1:Any}",
	path = "from pathlib import Path\n\n${1:path} = Path(${2})",
	argp = "import argparse\n\nparser = argparse.ArgumentParser()\nparser.add_argument(\"${1:--flag}\")\nargs = parser.parse_args()\n${0}",
	-- }}}
}
-- }}}

-- vim: foldmethod=marker foldlevel=0
