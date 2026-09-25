# Dotfiles

Personal configuration files for daily development tools on macOS and Windows.

## Setup

The repo uses [mise](https://mise.jdx.dev) tasks in `mise.toml` as the source of truth for what gets installed into `$HOME`. Run `mise trust` once in the repo, `mise install` to set up the pinned tools (Rust for the helper binaries in `crates/`), and `mise run build` to build `setup-tool` into `bin/` (gitignored); then `mise run setup-tool -ad` shows what would change. `mise tasks` lists every task.

- `mise run install` (or just `mise run`): copy every tool's files with `setup-tool --all`, then install Vim plugins and VS Code extensions
- `mise run build`: build `crates/setup-tool` in release mode and copy the binary to `bin/`; run it again after changing the crate
- `mise run setup-tool pi`: copy a tool's files into `$HOME` with `bin/setup-tool`, copying only files that differ and overwriting them. Tools are named in the root `manifest.json` (alphanumeric name -> manifest path, e.g. `pi` -> `tools/pi/manifest.json`), and several can be given at once (`mise run setup-tool fish tmux`); add `-d`/`--diff` (e.g. `mise run setup-tool -d pi`) to only show how each copy differs from the repo
- `mise run setup-tool -a` (`--all`): set up every tool in the root `manifest.json`; combine with `-d` (`-ad`) to only show differences
- `mise run setup-tool -p pi` (`--pull`): copy the installed files back into the repo, for changes made outside the repo (e.g. an app edited its settings); only takes tool names, not `--all`, and a recursive entry only pulls files the repo already has. Combine with `-d` (`-pd pi`) to see what would change in the repo first
- `mise run setup-tool:dev -- <args>`: run `setup-tool` from source with `cargo run` while developing the crate; arguments pass straight through (`mise run setup-tool:dev -- -h` for its help)
- `mise run vim`: install vim-plug and the plugins declared in the posix `.vimrc`
- `mise run vscode-extensions`: install the VS Code extensions listed in `tools/vscode/<os>/extensions.txt`
- `mise run lint`: run clippy on the Rust helper crates in `crates/` with the strict workspace lints from `Cargo.toml`
- `mise run clean`: remove symlinks left by the old link-based install; run it once on macOS before the first `setup-tool` run

Files are copied, not linked, so edits that apps make in `$HOME` stay there until you bring them back into the repo. Run `mise run setup-tool -ad` before installing to see what would change.

## Tools

Each tool lives in `tools/<name>/` with a `manifest.json` and one folder per platform: `common/` (everywhere), `posix/` (macOS and Linux), `macos/`, or `windows/`.

| Tool | Platforms | Installs to |
|---|---|---|
| `claude` | all | `~/.claude/statusline.js` (Claude Code status line; enable with `"statusLine": {"type": "command", "command": "node ~/.claude/statusline.js"}` in `~/.claude/settings.json`) |
| `fish` | macOS | `~/.config/fish/{config.fish,fish_plugins}` |
| `gh` | macOS | `~/.config/gh/config.yml` (authentication stays outside the repo) |
| `ghostty` | macOS | `~/.config/ghostty/` (`config`, `shaders/`, `auto/`) |
| `git` | all | `~/.gitconfig` (shared), which includes `~/.gitconfig.platform` (macOS or Windows settings) |
| `meld` | macOS | `~/.local/bin/meld` (CLI wrapper for Meld.app) |
| `mise` | macOS, Windows | `~/.config/mise/config.toml` (global tools and settings) |
| `pi` | all | `~/.pi/agent/` (settings profile per platform, web-search preferences, extensions) |
| `powershell` | Windows | `$PROFILE` |
| `sqlfluff` | macOS | `~/.config/sqlfluff/.sqlfluff` |
| `tmux` | macOS | `~/.tmux.conf` |
| `vim` | all | `~/.vimrc` (macOS and Linux), `~/_vimrc` (Windows) |
| `vscode` | macOS, Windows | VS Code user `settings.json` (both) and `keybindings.json` (macOS); `extensions.txt` is read by `mise run vscode-extensions` |
| `windowsterminal` | Windows | Windows Terminal `settings.json` |
| `zsh` | macOS | `~/.zshenv`, `~/.zshrc` (fish is the interactive shell; macOS programs still use zsh) |

## Layout

- `manifest.json`: maps tool names to their manifests for `setup-tool`
- `tools/<name>/manifest.json`: a tool's files. Each file's `platform` (`common` by default, `group:posix`, `group:linux`, `macos`, `wsl`, or `windows`) picks where it applies and its source folder (`tools/<name>/<platform>/`, without `group:`); destinations are expanded by pwsh on Windows and bash elsewhere (so `$HOME`, `$PROFILE`, `$env:APPDATA` work), an absolute destination ignores `destinationRoot`, and `recursive: true` syncs every file under a source folder into a destination folder
- `crates/setup-tool/`: the Rust binary that reads the manifests; `schemas/` holds the JSON schemas the manifests point to with `$schema`, so editors validate and complete them
- `scripts/dotfiles.sh`: helpers for the Unix mise tasks
- `old/`: configuration no longer in use (Neovim, Zed, Emacs, Herdr, Starship, Jujutsu, Arch/i3, WSL, server, and outdated docs), kept for reference

## Vim

Vim 9.2 uses vim-plug for `vim-tmux-navigator`; run `mise run vim` to install both.
Use `:RepoDiff` or `<leader>gg` to open the current JJ or Git working-copy diff
in a disposable tab. Pass an optional directory, such as `:RepoDiff tools/vim`,
to use the nearest repository containing that directory and limit the diff to
that path. Changed files start collapsed; use Vim's standard `z` commands to
reveal a complete file entry, and press `q` to close the tab.

Use `:JjDiff` or `:GitDiff` for explicit revision comparisons. Both accept
no arguments for current working-copy changes, `from REV [directory]` for a
working-copy baseline, `show REV [directory]` for one revision's patch, or
`between REV1 REV2 [directory]` to compare endpoints.
