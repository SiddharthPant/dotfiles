-- JavaScript snippets {{{
return {
	-- Functions {{{
	fn = "function ${1:name}(${2:args}) {\n\t${0}\n}",
	afn = "const ${1:name} = (${2:args}) => {\n\t${0}\n}",
	aafn = "const ${1:name} = async (${2:args}) => {\n\t${0}\n}",
	iife = "(() => {\n\t${0}\n})()",
	class = "class ${1:Name} {\n\tconstructor(${2:args}) {\n\t\t${0}\n\t}\n}",
	-- }}}

	-- Imports / exports {{{
	imp = 'import ${1:name} from "${2:module}"',
	imn = 'import { ${1:name} } from "${2:module}"',
	exp = "export ${1:default }${2}",
	expf = "export function ${1:name}(${2:args}) {\n\t${0}\n}",
	-- }}}

	-- Control flow {{{
	try = "try {\n\t${1}\n} catch (${2:err}) {\n\t${0}\n}",
	["for"] = "for (let ${1:i} = 0; ${1:i} < ${2:arr}.length; ${1:i}++) {\n\t${0}\n}",
	forof = "for (const ${1:item} of ${2:items}) {\n\t${0}\n}",
	forin = "for (const ${1:key} in ${2:obj}) {\n\t${0}\n}",
	tern = "${1:cond} ? ${2:a} : ${3:b}",
	-- }}}

	-- Collections / async {{{
	map = "${1:items}.map((${2:item}) => ${3})",
	filter = "${1:items}.filter((${2:item}) => ${3})",
	reduce = "${1:items}.reduce((${2:acc}, ${3:item}) => {\n\t${0}\n\treturn ${2:acc}\n}, ${4:init})",
	prom = "new Promise((resolve, reject) => {\n\t${0}\n})",
	await = "const ${1:result} = await ${2:promise}",
	des = "const { ${1:prop} } = ${2:obj}",
	-- }}}

	-- Console {{{
	cl = "console.log(${1})",
	ce = "console.error(${1})",
	-- }}}

	-- React hooks {{{
	us = "const [${1:state}, set${2:State}] = useState(${3:initial})",
	ue = "useEffect(() => {\n\t${0}\n}, [${1:deps}])",
	uc = "const ${1:value} = useCallback((${2:args}) => {\n\t${0}\n}, [${3:deps}])",
	um = "const ${1:value} = useMemo(() => ${2:expr}, [${3:deps}])",
	-- }}}
}
-- }}}

-- vim: foldmethod=marker foldlevel=0
