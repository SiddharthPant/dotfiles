-- Go snippets {{{
return {
	-- Errors {{{
	err = "if err != nil {\n\treturn ${1:err}\n}",
	errf = 'if err != nil {\n\treturn fmt.Errorf("${1:wrap}: %w", err)\n}',
	errn = "if err != nil {\n\treturn nil, ${1:err}\n}",
	-- }}}

	-- Functions {{{
	fn = "func ${1:name}(${2:args}) ${3:error} {\n\t${0}\n}",
	method = "func (${1:r} *${2:Receiver}) ${3:name}(${4:args}) ${5:error} {\n\t${0}\n}",
	main = "func main() {\n\t${0}\n}",
	-- }}}

	-- Types {{{
	struct = "type ${1:Name} struct {\n\t${2:Field} ${3:string}\n}",
	iface = "type ${1:Name} interface {\n\t${2:Method}(${3:args}) ${4:error}\n}",
	const = "const ${1:Name} = ${2:value}",
	var = "var ${1:name} ${2:Type}",
	make = "make(${1:[]Type}, ${2:0}${3:, ${4:cap}})",
	map = "map[${1:string}]${2:Type}",
	-- }}}

	-- Control flow {{{
	["for"] = "for ${1:i} := ${2:0}; ${1:i} < ${3:n}; ${1:i}++ {\n\t${0}\n}",
	forr = "for ${1:_, }${2:v} := range ${3:items} {\n\t${0}\n}",
	switch = "switch ${1:expr} {\n\tcase ${2:val}:\n\t\t${0}\n}",
	sel = "select {\n\tcase ${1:v}, ${2:ok} := <-${3:ch}:\n\t\t${0}\n}",
	go = "go func() {\n\t${0}\n}()",
	defer = "defer ${1:fn}()",
	-- }}}

	-- Testing {{{
	test = "func Test${1:Name}(t *testing.T) {\n\t${0}\n}",
	bench = "func Benchmark${1:Name}(b *testing.B) {\n\tfor i := 0; i < b.N; i++ {\n\t\t${0}\n\t}\n}",
	tlog = 't.Logf("${1:%v}", ${2:v})',
	tfatal = 't.Fatalf("${1:%v}", ${2:err})',
	-- }}}
}
-- }}}

-- vim: foldmethod=marker foldlevel=0
