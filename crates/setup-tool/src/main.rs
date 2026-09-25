//! Copy tool files listed in manifest.json files into the home folder:
//! `cargo run -q -p setup-tool -- (-l|--list | [-d|--diff] (-a|--all | [-p|--pull] <tool>...))`.
//! The root manifest.json maps alphanumeric tool names to their manifests (e.g. "pi" ->
//! tools/pi/manifest.json); `--all` sets up every tool, and `--list` only prints each tool with
//! how many files it installs on this OS. Files are only copied when they differ;
//! `--diff` shows the differences instead. `--pull` copies the other way, from the home folder back
//! into the repo, for bringing changes made outside the repo back into it; it only takes tool names,
//! and for a recursive entry only pulls the files that the repo already has.
//!
//! Each file's `platform` (default "common") picks where it applies and the source folder next to
//! the manifest: "group:posix" -> posix/, "group:linux" -> linux/, "macos" -> macos/, and so on.
//! `destinationRoot` and `destination` are expanded by pwsh on Windows and bash elsewhere, so they
//! use that shell's variables (`$HOME`, `$env:APPDATA`, `$XDG_CONFIG_HOME`). A destination that is
//! absolute after expansion is used as is; otherwise it is relative to `destinationRoot`.
//! With `recursive: true`, `source` and `destination` are folders and every file under `source`
//! is synced; `source` must be a folder exactly when `recursive` is set.
use std::collections::BTreeMap;
use std::env;
use std::fmt;
use std::fs;
use std::io::ErrorKind;
use std::iter;
use std::mem;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::Instant;

use anyhow::{Context, Result, bail, ensure};
use clap::Parser;
use console::{Emoji, Style, style};
use indicatif::{ParallelProgressIterator, ProgressBar, ProgressFinish};
use rayon::prelude::*;
use serde::Deserialize;
use serde::de::DeserializeOwned;
use similar::{ChangeTag, TextDiff};

/// Maps tool names to their manifests. It and the paths in it are relative to the repo root,
/// where mise runs tasks.
const ROOT_MANIFEST: &str = "manifest.json";

#[derive(Parser)]
#[expect(clippy::struct_excessive_bools, reason = "clap flags")]
#[command(about = "Copy tool files listed in manifest.json files into the home folder")]
struct Args {
    /// Only show how each installed file differs from the repo; copy nothing
    #[arg(short, long)]
    diff: bool,
    /// Set up every tool listed in the root manifest.json
    #[arg(short, long, conflicts_with = "tools")]
    all: bool,
    /// Copy the installed files back into the repo instead; only with tool names, not --all
    #[arg(short, long, conflicts_with = "all")]
    pull: bool,
    /// List every tool in the root manifest.json and how many files it installs on this OS
    #[arg(short, long, conflicts_with_all = ["all", "diff", "pull", "tools"])]
    list: bool,
    /// Tools to set up by their name in the root manifest.json, e.g. pi
    #[arg(required_unless_present_any = ["all", "list"])]
    tools: Vec<String>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct RootManifest {
    /// Editor schema reference; ignored.
    #[serde(rename = "$schema")]
    _schema: Option<String>,
    manifests: BTreeMap<String, PathBuf>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
struct Manifest {
    /// Editor schema reference; ignored.
    #[serde(rename = "$schema")]
    _schema: Option<String>,
    destination_root: String,
    files: Vec<FileEntry>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct FileEntry {
    #[serde(default)]
    platform: Platform,
    source: PathBuf,
    destination: String,
    /// `source` and `destination` are folders, and every file under `source` is synced.
    #[serde(default)]
    recursive: bool,
}

/// Where a file applies; also names its source folder next to the manifest.
#[derive(Deserialize, Default, Clone, Copy)]
#[serde(rename_all = "lowercase")]
enum Platform {
    #[default]
    Common,
    #[serde(rename = "group:posix")]
    PosixGroup,
    #[serde(rename = "group:linux")]
    LinuxGroup,
    Macos,
    Wsl,
    Windows,
}

#[derive(Clone, Copy, PartialEq)]
enum Os {
    Macos,
    Linux,
    Wsl,
    Windows,
}

impl Platform {
    fn includes(self, os: Os) -> bool {
        match self {
            Self::Common => true,
            Self::PosixGroup => os != Os::Windows,
            Self::LinuxGroup => matches!(os, Os::Linux | Os::Wsl),
            Self::Macos => os == Os::Macos,
            Self::Wsl => os == Os::Wsl,
            Self::Windows => os == Os::Windows,
        }
    }

    const fn dir(self) -> &'static str {
        match self {
            Self::Common => "common",
            Self::PosixGroup => "posix",
            Self::LinuxGroup => "linux",
            Self::Macos => "macos",
            Self::Wsl => "wsl",
            Self::Windows => "windows",
        }
    }
}

impl Os {
    fn current() -> Self {
        if cfg!(windows) {
            Self::Windows
        } else if cfg!(target_os = "macos") {
            Self::Macos
        } else if env::var_os("WSL_DISTRO_NAME").is_some() {
            Self::Wsl
        } else {
            Self::Linux
        }
    }
}

/// A file to sync, ordered by destination so conflicting jobs sort next to each other.
#[derive(PartialEq, Eq, PartialOrd, Ord)]
struct Job {
    dst: PathBuf,
    src: PathBuf,
}

fn read_json<T: DeserializeOwned>(path: &Path) -> Result<T> {
    let text =
        fs::read_to_string(path).with_context(|| format!("failed to read {}", path.display()))?;
    serde_json::from_str(&text).with_context(|| format!("invalid {}", path.display()))
}

/// Read the root manifest and check that every tool name is alphanumeric.
fn read_root() -> Result<RootManifest> {
    let root: RootManifest = read_json(Path::new(ROOT_MANIFEST))?;
    if let Some(name) = root
        .manifests
        .keys()
        .find(|name| name.is_empty() || !name.chars().all(|c| c.is_ascii_alphanumeric()))
    {
        bail!("{ROOT_MANIFEST}: tool name {name:?} must be alphanumeric");
    }
    Ok(root)
}

fn read_manifests<'a>(
    paths: impl IntoIterator<Item = &'a PathBuf>,
) -> Result<Vec<(PathBuf, Manifest)>> {
    paths
        .into_iter()
        .map(|path| Ok((normalize(path), read_json(path)?)))
        .collect()
}

/// Read the manifests of the requested tools (all of them for `--all`).
fn load(args: &Args) -> Result<Vec<(PathBuf, Manifest)>> {
    let root = read_root()?;
    let names: Vec<&str> = root.manifests.keys().map(String::as_str).collect();
    let paths: Vec<&PathBuf> = if args.all {
        root.manifests.values().collect()
    } else {
        args.tools
            .iter()
            .map(|tool| {
                root.manifests.get(tool).with_context(|| {
                    format!("unknown tool {tool:?}; available: {}", names.join(", "))
                })
            })
            .collect::<Result<_>>()?
    };
    read_manifests(paths)
}

/// Print every tool with how many files it installs on this OS, dimming tools with none.
/// All tools resolve in one shell call, and each job is matched back to its tool by the folder
/// its source comes from.
fn list() -> Result<()> {
    let root = read_root()?;
    let manifests = read_manifests(root.manifests.values())?;
    let jobs = resolve(&manifests, Os::current())?;
    let width = root.manifests.keys().map(String::len).max().unwrap_or(0);
    for (name, (path, _)) in root.manifests.keys().zip(&manifests) {
        let count = (jobs.iter())
            .filter(|job| job.src.starts_with(parent(path)))
            .count();
        let line = style(format!("{name:width$}  {count} file(s)"));
        println!("{}", if count == 0 { line.dim() } else { line });
    }
    Ok(())
}

fn parent(path: &Path) -> &Path {
    path.parent().unwrap_or_else(|| Path::new(""))
}

/// Rebuild a path with native separators.
fn normalize(path: &Path) -> PathBuf {
    path.components().collect()
}

/// The first `$env:NAME` or `${env:NAME}` in `path` that is not set. pwsh expands those to ""
/// even under `Set-StrictMode`, so they are checked here instead.
fn unset_env_var(path: &str) -> Option<String> {
    path.split('$').skip(1).find_map(|part| {
        let braced = part.strip_prefix('{');
        let rest = braced.unwrap_or(part);
        let name: String = rest
            .get(4..)
            .filter(|_| {
                rest.get(..4)
                    .is_some_and(|p| p.eq_ignore_ascii_case("env:"))
            })?
            .chars()
            .take_while(|&c| {
                if braced.is_some() {
                    c != '}'
                } else {
                    c.is_alphanumeric() || c == '_'
                }
            })
            .collect();
        (name.is_empty() || env::var_os(&name).is_none()).then_some(name)
    })
}

/// Expand all paths in one shell call, one output line per path.
fn expand(paths: &[&str]) -> Result<Vec<String>> {
    if paths.is_empty() {
        return Ok(Vec::new());
    }
    let quoted: Vec<String> = paths.iter().map(|p| format!("\"{p}\"")).collect();
    let output = if cfg!(windows) {
        if let Some(name) = paths.iter().find_map(|path| unset_env_var(path)) {
            bail!("expanding paths failed: $env:{name} is not set");
        }
        // Fail on unset variables like bash's -u, and print UTF-8 instead of the console code page
        let script = format!(
            "$ErrorActionPreference = 'Stop'; Set-StrictMode -Version Latest; \
             [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false); {}",
            quoted.join(";")
        );
        Command::new("pwsh")
            .args(["-NoProfile", "-Command", &script])
            .output()
    } else {
        Command::new("bash")
            .args(["-uc", &format!("printf '%s\\n' {}", quoted.join(" "))])
            .output()
    }
    .context("failed to start the shell to expand paths")?;
    ensure!(
        output.status.success(),
        "expanding paths failed: {}",
        String::from_utf8_lossy(&output.stderr).trim()
    );
    let expanded: Vec<String> = String::from_utf8(output.stdout)?
        .lines()
        .map(str::to_owned)
        .collect();
    ensure!(
        expanded.len() == paths.len(),
        "expanding {paths:?} gave {expanded:?}"
    );
    Ok(expanded)
}

/// Turn the manifests' files for this OS into jobs, expanding all their paths in one shell call.
fn resolve(manifests: &[(PathBuf, Manifest)], os: Os) -> Result<Vec<Job>> {
    let selected: Vec<(&Path, &Manifest, Vec<&FileEntry>)> = manifests
        .iter()
        .map(|(path, manifest)| {
            let files: Vec<&FileEntry> = (manifest.files.iter())
                .filter(|file| file.platform.includes(os))
                .collect();
            (path.as_path(), manifest, files)
        })
        .filter(|(_, _, files)| !files.is_empty())
        .collect();
    let paths: Vec<&str> = selected
        .iter()
        .flat_map(|(_, manifest, files)| {
            iter::once(manifest.destination_root.as_str())
                .chain(files.iter().map(|file| file.destination.as_str()))
        })
        .collect();
    let mut expanded = expand(&paths)?.into_iter();

    let mut jobs = Vec::new();
    for (path, _, files) in selected {
        let root = expanded
            .next()
            .context("expanding paths gave too few lines")?;
        for file in files {
            let destination = expanded
                .next()
                .context("expanding paths gave too few lines")?;
            let src = normalize(&parent(path).join(file.platform.dir()).join(&file.source));
            let dst = normalize(&Path::new(&root).join(destination));
            match (file.recursive, src.is_dir()) {
                (false, false) => jobs.push(Job { dst, src }),
                (true, true) => {
                    let mut sources = Vec::new();
                    walk(&src, &mut sources)?;
                    for source in sources {
                        let dst = dst.join(source.strip_prefix(&src)?);
                        jobs.push(Job { dst, src: source });
                    }
                }
                (true, false) => bail!(
                    "{}: {} is recursive but not a folder",
                    path.display(),
                    src.display()
                ),
                (false, true) => bail!(
                    "{}: {} is a folder; set \"recursive\": true to sync it",
                    path.display(),
                    src.display()
                ),
            }
        }
    }
    Ok(jobs)
}

/// Collect every file under `dir`.
fn walk(dir: &Path, files: &mut Vec<PathBuf>) -> Result<()> {
    for entry in fs::read_dir(dir).with_context(|| format!("failed to read {}", dir.display()))? {
        let path = entry?.path();
        if path.is_dir() {
            walk(&path, files)?;
        } else {
            files.push(path);
        }
    }
    Ok(())
}

fn line_number(index: Option<usize>) -> String {
    index.map_or_else(|| "    ".into(), |i| format!("{:<4}", i.saturating_add(1)))
}

/// A line diff with the changed words emphasized, like similar's terminal-inline example.
/// console drops the styling when stdout is not a terminal.
struct DiffView<'a> {
    dst: &'a Path,
    src: &'a Path,
    old: &'a str,
    new: &'a str,
}

impl fmt::Display for DiffView<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let diff = TextDiff::from_lines(self.old, self.new);
        writeln!(
            f,
            "{}",
            style(format!("--- {}", self.dst.display())).red().bold()
        )?;
        writeln!(
            f,
            "{}",
            style(format!("+++ {}", self.src.display())).green().bold()
        )?;
        for (i, group) in diff.grouped_ops(3).iter().enumerate() {
            if i > 0 {
                writeln!(f, "{}", style("-".repeat(80)).dim())?;
            }
            for change in group.iter().flat_map(|op| diff.iter_inline_changes(op)) {
                let (sign, line_style) = match change.tag() {
                    ChangeTag::Delete => ("-", Style::new().red()),
                    ChangeTag::Insert => ("+", Style::new().green()),
                    ChangeTag::Equal => (" ", Style::new().dim()),
                };
                write!(
                    f,
                    "{}{} |{}",
                    style(line_number(change.old_index())).dim(),
                    style(line_number(change.new_index())).dim(),
                    line_style.apply_to(sign).bold()
                )?;
                let changed = change.tag() != ChangeTag::Equal;
                for (emphasized, value) in change.iter_strings_lossy() {
                    // Make changed whitespace visible. similar never emphasizes line endings, so a
                    // changed line shows its \r everywhere; the line break itself stays as is.
                    let visible: String = value
                        .chars()
                        .map(|c| match c {
                            ' ' if emphasized => '·',
                            '\t' if emphasized => '→',
                            '\r' if changed => '␍',
                            c => c,
                        })
                        .collect();
                    let visible = line_style.apply_to(visible);
                    if emphasized {
                        write!(f, "{}", visible.underlined().on_black())?;
                    } else {
                        write!(f, "{visible}")?;
                    }
                }
                if change.missing_newline() {
                    writeln!(f)?;
                    writeln!(f, "{}", style("\\ No newline at end of file").dim())?;
                }
            }
        }
        Ok(())
    }
}

/// Copy `src` over `dst` when they differ, or with `diff` only describe the difference.
fn sync(Job { dst, src }: &Job, diff: bool) -> Result<String> {
    let new = fs::read(src).with_context(|| format!("failed to read {}", src.display()))?;
    let old = match fs::read(dst) {
        Ok(old) => Some(old),
        Err(err) if err.kind() == ErrorKind::NotFound => None,
        Err(err) => return Err(err).context(format!("failed to read {}", dst.display())),
    };
    match old {
        Some(old) if old == new => Ok(format!("{} {}\n", style("same").dim(), dst.display())),
        None if diff => Ok(format!("{} {}\n", style("new").green(), dst.display())),
        Some(old) if diff => Ok(DiffView {
            dst,
            src,
            old: &String::from_utf8_lossy(&old),
            new: &String::from_utf8_lossy(&new),
        }
        .to_string()),
        _ => {
            if let Some(parent) = dst.parent() {
                fs::create_dir_all(parent)?;
            }
            // Write a temporary file next to dst and rename it over dst, so a failed write leaves
            // dst intact and an old symlink is replaced instead of written through
            let mut tmp = dst.as_os_str().to_owned();
            tmp.push(".setup-tool.tmp");
            let tmp = PathBuf::from(tmp);
            let written = fs::write(&tmp, &new)
                .and_then(|()| fs::set_permissions(&tmp, fs::metadata(src)?.permissions()))
                .and_then(|()| fs::rename(&tmp, dst));
            if let Err(err) = written {
                fs::remove_file(&tmp).ok();
                return Err(err).with_context(|| format!("failed to copy to {}", dst.display()));
            }
            Ok(format!(
                "{} {} -> {}\n",
                style("copied").green(),
                src.display(),
                dst.display()
            ))
        }
    }
}

/// Print a yarn-style step line; steps and progress bars go to stderr so stdout stays the result.
fn step(number: u8, emoji: Emoji, message: &str) {
    let counter = style(format!("[{number}/3]")).bold().dim().for_stderr();
    eprintln!("{counter} {emoji}{message}");
}

/// A progress bar that clears itself when done; indicatif hides it when stderr is not a terminal.
fn progress(len: usize) -> ProgressBar {
    ProgressBar::new(u64::try_from(len).unwrap_or(u64::MAX)).with_finish(ProgressFinish::AndClear)
}

fn main() -> Result<()> {
    let started = Instant::now();
    let args = Args::parse();
    if args.list {
        return list();
    }

    step(1, Emoji("📃 ", ""), "Reading manifests...");
    let manifests = load(&args)?;

    step(2, Emoji("🔍 ", ""), "Resolving destinations...");
    let mut jobs = resolve(&manifests, Os::current())?;
    if args.pull {
        for job in &mut jobs {
            mem::swap(&mut job.src, &mut job.dst);
        }
    }
    // A tool named twice is harmless, but two sources for one destination would race
    jobs.sort();
    jobs.dedup();
    if let Some([a, b]) = jobs
        .windows(2)
        .find(|pair| matches!(pair, [a, b] if a.dst == b.dst))
    {
        bail!(
            "{} is the destination of both {} and {}",
            a.dst.display(),
            a.src.display(),
            b.src.display()
        );
    }

    if args.diff {
        step(3, Emoji("🔎 ", ""), "Comparing files...");
    } else if args.pull {
        step(3, Emoji("🚚 ", ""), "Pulling files into the repo...");
    } else {
        step(3, Emoji("🚚 ", ""), "Copying files...");
    }
    let results: Vec<Result<String>> = jobs
        .par_iter()
        .progress_with(progress(jobs.len()))
        .map(|job| sync(job, args.diff))
        .collect();
    for result in &results {
        match result {
            Ok(output) => print!("{output}"),
            Err(err) => eprintln!("{} {err:#}", style("error:").red().bold().for_stderr()),
        }
    }
    let failures = results.iter().filter(|result| result.is_err()).count();
    ensure!(failures == 0, "{failures} file(s) failed");
    eprintln!(
        "{}Done in {}ms",
        Emoji("✨ ", ""),
        started.elapsed().as_millis()
    );
    Ok(())
}
