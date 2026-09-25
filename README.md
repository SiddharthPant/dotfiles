# Dotfiles

Personal configuration for macOS and Windows, installed by [mise](https://mise.jdx.dev) tasks in `mise.toml`.

## Setup

```sh
mise trust && mise install   # pinned Rust toolchain
mise run build               # build setup-tool into bin/ (gitignored)
mise run setup-tool -ad      # preview what would change
mise run                     # install everything
```

- `install` (the default): `setup-tool --all`, then Vim plugins and VS Code extensions
- `build`: build `crates/setup-tool` in release mode into `bin/`; rerun after changing the crate
- `setup-tool <tool>...` or `-a`: copy tool files into the home folder when they differ; `-d` only shows the diffs, `-p <tool>` pulls the installed files back into the repo (not with `-a`; a recursive entry only pulls files the repo already has)
- `setup-tool:dev -- <args>`: the same, from source with `cargo run`
- `lint`: clippy with the strict workspace lints from `Cargo.toml`
- `vim`, `vscode-extensions`: install vim-plug plugins, and the extensions in `tools/vscode/<os>/extensions.txt`
- `clean`: remove symlinks left by the old link-based install (once, on macOS)

Files are copied, not linked. Apps that edit their own settings (VS Code, Windows Terminal, `gh`, `git config --global`, `mise use -g`, fisher, Ghostty's theme) make copies drift: check with `-d`, bring changes back with `-p`.

## Layout

- `manifest.json`: the list of tools, mapping each alphanumeric name to `tools/<name>/manifest.json`
- `tools/<name>/`: a manifest plus a source folder per platform (`common/`, `posix/`, `linux/`, `macos/`, `wsl/`, `windows/`). Each file's `platform` (default `common`, or `group:posix`, `group:linux`, ...) picks its folder; `destinationRoot` and `destination` are expanded by pwsh on Windows and bash elsewhere (`$HOME`, `$PROFILE`, `$env:APPDATA`); `recursive: true` syncs a whole folder
- `crates/setup-tool/`: the Rust copier; `schemas/` validates the manifests through `$schema`
- `scripts/dotfiles.sh`: helpers for the Unix tasks
- `old/`: configuration no longer used (Neovim, Zed, Emacs, Herdr, Starship, Jujutsu, Arch/i3, WSL, server), kept for reference
