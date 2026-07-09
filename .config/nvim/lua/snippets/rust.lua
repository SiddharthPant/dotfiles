-- Rust snippets {{{
return {
	-- Functions / methods {{{
	fn = "fn ${1:name}(${2:args}) ${3:-> ${4:Ret} }{\n\t${0}\n}",
	pfn = "pub fn ${1:name}(${2:args}) ${3:-> ${4:Ret} }{\n\t${0}\n}",
	afn = "async fn ${1:name}(${2:args}) ${3:-> ${4:Ret} }{\n\t${0}\n}",
	pafn = "pub async fn ${1:name}(${2:args}) ${3:-> ${4:Ret} }{\n\t${0}\n}",
	method = "fn ${1:name}(&self${2:, args}) ${3:-> ${4:Ret} }{\n\t${0}\n}",
	methodm = "fn ${1:name}(&mut self${2:, args}) ${3:-> ${4:Ret} }{\n\t${0}\n}",
	new = "pub fn new(${1:args}) -> Self {\n\tSelf {\n\t\t${0}\n\t}\n}",
	main = "fn main() {\n\t${0}\n}",
	amain = '#[tokio::main]\nasync fn main() -> Result<(), Box<dyn std::error::Error>> {\n\t${0}\n\tOk(())\n}',
	-- }}}

	-- Types {{{
	struct = "struct ${1:Name} {\n\t${2:field}: ${3:Type},\n}",
	pstruct = "pub struct ${1:Name} {\n\tpub ${2:field}: ${3:Type},\n}",
	tstruct = "struct ${1:Name}<${2:T}> {\n\t${3:field}: ${2:T},\n}",
	tuple = "struct ${1:Name}(${2:Type});",
	enum = "enum ${1:Name} {\n\t${2:Variant},\n}",
	penum = "pub enum ${1:Name} {\n\t${2:Variant},\n}",
	union = "union ${1:Name} {\n\t${2:field}: ${3:Type},\n}",
	type = "type ${1:Alias} = ${2:Type};",
	const = "const ${1:NAME}: ${2:Type} = ${3:value};",
	static = "static ${1:NAME}: ${2:Type} = ${3:value};",
	staticm = "static mut ${1:NAME}: ${2:Type} = ${3:value};",
	-- }}}

	-- Impl / traits {{{
	impl = "impl ${1:Type} {\n\t${0}\n}",
	implt = "impl<${1:T}> ${2:Type}<${1:T}> {\n\t${0}\n}",
	implf = "impl ${1:Trait} for ${2:Type} {\n\t${0}\n}",
	implft = "impl<${1:T}> ${2:Trait} for ${3:Type}<${1:T}> {\n\t${0}\n}",
	trait = "trait ${1:Name} {\n\tfn ${2:method}(&self)${3: -> ${4:Ret}};\n}",
	ptrait = "pub trait ${1:Name} {\n\tfn ${2:method}(&self)${3: -> ${4:Ret}};\n}",
	def = "fn ${1:method}(&self) ${2:-> ${3:Ret} }{\n\t${0}\n}",
	where = "where\n\t${1:T}: ${2:Trait},",
	-- }}}

	-- Control flow {{{
	match = "match ${1:expr} {\n\t${2:pattern} => ${3:expr},\n\t${0}\n}",
	matcha = "match ${1:expr} {\n\tOk(${2:v}) => ${3:v},\n\tErr(${4:e}) => ${5:return Err(e.into())},\n}",
	matcho = "match ${1:expr} {\n\tSome(${2:v}) => ${3:v},\n\tNone => ${4:return None},\n}",
	iflet = "if let ${1:Some(x)} = ${2:expr} {\n\t${0}\n}",
	ifleto = "if let Some(${1:x}) = ${2:expr} {\n\t${0}\n}",
	iflete = "if let Err(${1:e}) = ${2:expr} {\n\t${0}\n}",
	whilelet = "while let ${1:Some(x)} = ${2:expr} {\n\t${0}\n}",
	["for"] = "for ${1:item} in ${2:iter} {\n\t${0}\n}",
	loop = "loop {\n\t${0}\n}",
	["if"] = "if ${1:cond} {\n\t${0}\n}",
	ife = "if ${1:cond} {\n\t${2}\n} else {\n\t${0}\n}",
	-- }}}

	-- Error / option handling {{{
	letok = "let ${1:val} = ${2:expr}?;",
	letsome = "let Some(${1:val}) = ${2:expr} else {\n\t${3:return None;}\n};",
	letelse = "let ${1:pat} = ${2:expr} else {\n\t${3:return;}\n};",
	ok = "Ok(${1:value})",
	err = "Err(${1:error})",
	some = "Some(${1:value})",
	none = "None",
	unwrap = "${1:expr}.unwrap()",
	expect = '${1:expr}.expect("${2:msg}")',
	maperr = '${1:expr}.map_err(|e| ${2:anyhow!("${3}: {e}")})?',
	context = '${1:expr}.context("${2:msg}")?',
	bail = 'bail!("${1:msg}");',
	anyhow = 'anyhow!("${1:msg}")',
	thiserror = '#[derive(Debug, thiserror::Error)]\nenum ${1:Error} {\n\t#[error("${2:msg}")]\n\t${3:Variant},\n}',
	-- }}}

	-- Attributes / macros {{{
	der = "#[derive(${1:Debug, Clone})]",
	derfull = "#[derive(Debug, Clone, PartialEq, Eq, Hash)]",
	derserde = "#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]",
	allow = "#[allow(${1:dead_code})]",
	cfg = '#[cfg(${1:feature = "${2:name}"})]',
	cfgattr = '#[cfg_attr(${1:feature = "${2:name}"}, ${3:derive(Debug)})]',
	inline = "#[inline]",
	must = "#[must_use]",
	repr = "#[repr(${1:C})]",
	doc = "/// ${1:docs}",
	todo = 'todo!("${1}")',
	unimplemented = 'unimplemented!("${1}")',
	unreachable = 'unreachable!("${1}")',
	panic = 'panic!("${1}")',
	assert = "assert!(${1:cond});",
	asserteq = "assert_eq!(${1:left}, ${2:right});",
	assertne = "assert_ne!(${1:left}, ${2:right});",
	debugassert = "debug_assert!(${1:cond});",
	-- }}}

	-- Logging / print {{{
	pl = 'println!("${1:{}}", ${2});',
	pe = 'eprintln!("${1:{}}", ${2});',
	pf = 'print!("${1:{}}", ${2});',
	fmt = 'format!("${1:{}}", ${2})',
	dbg = "dbg!(&${1:expr});",
	log = 'tracing::${1:info}!("${2:msg}");',
	logd = 'tracing::debug!(${1:?value}, "${2:msg}");',
	logerr = 'tracing::error!(error = %${1:e}, "${2:msg}");',
	-- }}}

	-- Collections / iterators {{{
	vec = "vec![${1}]",
	vecnew = "Vec::new()",
	vecwith = "Vec::with_capacity(${1:n})",
	hashmap = "HashMap::new()",
	hashset = "HashSet::new()",
	btreemap = "BTreeMap::new()",
	iter = "${1:items}.iter()${2:.map(|${3:x}| ${4:x})}${5:.collect::<Vec<_>>()}",
	intoiter = "${1:items}.into_iter()${2:.map(|${3:x}| ${4:x})}${5:.collect::<Vec<_>>()}",
	filter = "${1:items}.into_iter().filter(|${2:x}| ${3:pred}).collect::<Vec<_>>()",
	mapc = "${1:items}.into_iter().map(|${2:x}| ${3:x}).collect::<${4:Vec<_>>>()",
	collect = ".collect::<${1:Vec<_>>>()",
	-- }}}

	-- Modules / use / visibility {{{
	mod = "mod ${1:name};",
	modb = "mod ${1:name} {\n\t${0}\n}",
	use = "use ${1:path};",
	usep = "use ${1:path}::{${2:Item}};",
	pubuse = "pub use ${1:path};",
	pub = "pub ${1}",
	pubc = "pub(crate) ${1}",
	-- }}}

	-- Testing {{{
	test = "#[test]\nfn ${1:name}() {\n\t${0}\n}",
	testres = "#[test]\nfn ${1:name}() -> Result<(), Box<dyn std::error::Error>> {\n\t${0}\n\tOk(())\n}",
	modtest = "#[cfg(test)]\nmod tests {\n\tuse super::*;\n\n\t#[test]\n\tfn ${1:name}() {\n\t\t${0}\n\t}\n}",
	tokio_test = "#[tokio::test]\nasync fn ${1:name}() {\n\t${0}\n}",
	should_panic = '#[test]\n#[should_panic(expected = "${1:msg}")]\nfn ${2:name}() {\n\t${0}\n}',
	ignore = "#[test]\n#[ignore]\nfn ${1:name}() {\n\t${0}\n}",
	bench = "#[bench]\nfn ${1:name}(b: &mut test::Bencher) {\n\tb.iter(|| {\n\t\t${0}\n\t});\n}",
	-- }}}

	-- Concurrency / async {{{
	spawn = "tokio::spawn(async move {\n\t${0}\n});",
	spawnb = "tokio::task::spawn_blocking(move || {\n\t${0}\n});",
	select = "tokio::select! {\n\t${1:biased;}\n\t${2:res} = ${3:fut} => {\n\t\t${0}\n\t}\n}",
	sleep = "tokio::time::sleep(std::time::Duration::from_millis(${1:100})).await;",
	timeout = "tokio::time::timeout(std::time::Duration::from_secs(${1:5}), ${2:fut}).await?;",
	arc = "Arc::new(${1:value})",
	mutex = "Mutex::new(${1:value})",
	rwl = "RwLock::new(${1:value})",
	channel = "let (${1:tx}, mut ${2:rx}) = tokio::sync::mpsc::channel(${3:32});",
	oneshot = "let (${1:tx}, ${2:rx}) = tokio::sync::oneshot::channel();",
	-- }}}

	-- FFI / unsafe {{{
	unsafe = "unsafe {\n\t${0}\n}",
	extern = 'extern "C" {\n\t${0}\n}',
	no_mangle = '#[no_mangle]\npub extern "C" fn ${1:name}(${2:args}) ${3:-> ${4:Ret} }{\n\t${0}\n}',
	-- }}}

	-- Common crates / patterns {{{
	from = "impl From<${1:Src}> for ${2:Dst} {\n\tfn from(${3:value}: ${1:Src}) -> Self {\n\t\t${0}\n\t}\n}",
	tryfrom = "impl TryFrom<${1:Src}> for ${2:Dst} {\n\ttype Error = ${3:anyhow::Error};\n\n\tfn try_from(${4:value}: ${1:Src}) -> Result<Self, Self::Error> {\n\t\t${0}\n\t}\n}",
	display = "impl std::fmt::Display for ${1:Type} {\n\tfn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {\n\t\twrite!(f, \"${2:{}}\", ${3:self.field})\n\t}\n}",
	default = "impl Default for ${1:Type} {\n\tfn default() -> Self {\n\t\tSelf {\n\t\t\t${0}\n\t\t}\n\t}\n}",
	drop = "impl Drop for ${1:Type} {\n\tfn drop(&mut self) {\n\t\t${0}\n\t}\n}",
	asref = "impl AsRef<${1:T}> for ${2:Type} {\n\tfn as_ref(&self) -> &${1:T} {\n\t\t${0}\n\t}\n}",
	borrow = "impl std::borrow::Borrow<${1:T}> for ${2:Type} {\n\tfn borrow(&self) -> &${1:T} {\n\t\t${0}\n\t}\n}",
	result = "Result<${1:T}, ${2:anyhow::Error}>",
	option = "Option<${1:T}>",
	boxd = "Box::new(${1:value})",
	rc = "Rc::new(${1:value})",
	cow = "Cow::Borrowed(${1:value})",
	once_cell = "static ${1:NAME}: once_cell::sync::Lazy<${2:Type}> = once_cell::sync::Lazy::new(|| {\n\t${0}\n});",
	lazy = "static ${1:NAME}: std::sync::LazyLock<${2:Type}> = std::sync::LazyLock::new(|| {\n\t${0}\n});",
	env = 'std::env::var("${1:VAR}")?',
	args = "let args: Vec<String> = std::env::args().collect();",
	fsread = "std::fs::read_to_string(${1:path})?",
	fswrite = "std::fs::write(${1:path}, ${2:contents})?",
	pathbuf = "std::path::PathBuf::from(${1:path})",
	duration = "std::time::Duration::from_${1:millis}(${2:100})",
	instant = "let ${1:start} = std::time::Instant::now();",
	thread = "std::thread::spawn(move || {\n\t${0}\n});",
	lock = "let ${1:guard} = ${2:mutex}.lock().unwrap();",
	clone = "${1:value}.clone()",
	to_string = "${1:value}.to_string()",
	into = "${1:value}.into()",
	as_str = "${1:value}.as_str()",
	as_ref = "${1:value}.as_ref()",
	as_mut = "${1:value}.as_mut()",
	to_owned = "${1:value}.to_owned()",
	parse = '${1:s}.parse::<${2:i32}>()?',
	-- }}}
}
-- }}}

-- vim: foldmethod=marker foldlevel=0
