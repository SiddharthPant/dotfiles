# AGENTS.md

This repository contains personal dotfiles for macOS and Windows. `mise.toml` tasks are the source of truth for what gets installed into `$HOME`; inspect them before changing setup or installation behavior. Tool files are copied (never linked) by `setup-tool`, a Rust binary in `crates/setup-tool`, from the per-tool manifests listed in the root `manifest.json`; mise tasks add the steps that are not file copies (Vim plugins, VS Code extensions). Helper programs are Rust binary crates in `crates/` (a Cargo workspace at the repo root, toolchain pinned in `mise.toml` `[tools]`); verify them with `mise run lint` (clippy with the strict workspace lints from `Cargo.toml`). `mise run setup-tool` runs the release binary that `mise run build` copies to the gitignored `bin/`; while changing the crate, run it from source with `mise run setup-tool:dev -- <args>`.

Each tool lives in `tools/<name>/`: `manifest.json` (validated by `crates/setup-tool/schemas/`) plus a source folder per platform (`common/`, `posix/`, `macos/`, `windows/`). Current tools: shells in `tools/{fish,zsh,powershell}/`; terminals in `tools/{ghostty,tmux,windowsterminal}/`; editors in `tools/{vim,vscode}/` (`.vimrc` for macOS and Linux, `_vimrc` for Windows); and tool configuration in `tools/{git,gh,mise,sqlfluff,meld,pi,claude}/` (`mise` has a macOS and a Windows global config). `old/` holds configuration that is no longer used (Neovim, Zed, Emacs, Herdr, Starship, Jujutsu, Arch/i3, WSL, server); do not edit or install it.

Make the smallest correct change and edit the existing responsible file rather than creating new modules.

When adding a managed file, add it to the tool's `manifest.json` (creating `tools/<name>/` and registering it in the root `manifest.json` for a new tool; names are alphanumeric) and list it in `README.md`. Never overwrite or delete real files in `$HOME` while testing; tasks change real files, so do not run them to verify changes without asking. `mise run setup-tool -d <tool>` (or `-ad`) only shows differences and is safe to run.

Copied files can drift from the repo, because apps edit their own settings (VS Code, Windows Terminal, fisher's `fish_plugins`, `gh`, `git config --global`, `mise use -g`, Ghostty's theme). Before changing a tool's source or re-copying it, compare it with its destination (`mise run setup-tool -d <tool>`) and reconcile:
- Identical: nothing to do.
- Only the destination changed (destination is newer than the source's last change, from both its mtime and `git log -1 --format=%ci -- <source>`, and the source has no uncommitted edits): fold the destination's changes into the source, then continue.
- Only the source changed: the destination is just behind; leave it for `setup-tool` to copy.
- Both changed, or it is unclear which side is newer: stop all further edits, show the diff with each side's timestamps, and wait for a human to decide.

Commit messages must be a single-line subject with no co-author trailers.
