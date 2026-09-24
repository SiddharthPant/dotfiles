# AGENTS.md

This repository contains personal dotfiles. `mise.toml` tasks are the source of truth for what gets installed into `$HOME`; inspect them before changing setup or installation behavior. Unix tasks (`run`) symlink files in bash via `scripts/dotfiles.sh`; Windows tasks (`run_windows`) copy files in PowerShell 7 via `scripts/dotfiles.ps1` and must never overwrite a diverged copy. Keep both working across macOS, Arch Linux, WSL, and Windows.

Shell configuration lives in `.zshenv`, `zshrc/{macos,arch-i3}/`, `.config/fish/{macos,wsl}/`, and `powershell/`; terminal configuration in `.tmux.conf`, `.config/ghostty/`, and `windows_terminal/`; editor configuration in `.config/{nvim,zed,emacs}/`, `.vimrc` (Unix) and `_vimrc` (Windows), and `vscode/`; and tool configuration in `.gitconfig`, `.config/{starship.toml,gh,jj,herdr,sqlfluff}`, `.config/mise/{macos,wsl}/config.toml`, `tools/pi/` (platform profiles and manifest), and `.claude/statusline.js` (Node Claude Code status line).

Neovim is the main active configuration. Keep behavior in `.config/nvim/init.lua`; custom snippets go in `.config/nvim/snippets/` in VS Code JSON format, and `.config/nvim/nvim-pack-lock.json` is managed by `vim.pack`. See `.config/nvim/README.md` for current usage and maintenance notes.

Make the smallest correct change and edit the existing responsible file rather than creating new modules. Keep related plugin setup and mappings together, use buffer-local mappings when appropriate, and prefer `vim.notify` for messages. Do not add leader mappings for commands that are already easy to invoke. For Neovim changes, verify with `nvim --headless -i NONE '+qa'`.

When adding a managed path, add it to the right `mise.toml` task (`run` and, if it applies to Windows, `run_windows`) and to the `clean` task, and list it in `README.md`. Never overwrite or delete real files in `$HOME` while testing; tasks change real files, so do not run them to verify changes without asking.

Copied files (Windows copies and seeded files such as `tools/pi/{macos,windows}/agent/settings.json`) can drift from the repo. Before changing a copied source or re-copying it, diff the source against its destination (`git diff --no-index <source> <destination>`) and reconcile:
- Identical: nothing to do.
- Only the destination changed (destination is newer than the source's last change, from both its mtime and `git log -1 --format=%ci -- <source>`, and the source has no uncommitted edits): fold the destination's changes into the source, then continue.
- Only the source changed: the destination is just behind; leave it for the install task to report.
- Both changed, or it is unclear which side is newer: stop all further edits, show the diff with each side's timestamps, and wait for a human to decide.

Commit messages must be a single-line subject with no co-author trailers.
