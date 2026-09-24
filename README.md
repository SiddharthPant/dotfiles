# Dotfiles

Personal configuration files for daily development tools.

## Setup

The repo uses [mise](https://mise.jdx.dev) tasks in `mise.toml` as the source of truth for what gets installed into `$HOME`. Run `mise trust` once in the repo, then `mise tasks` to list them.

- `mise run install` (or just `mise run`): auto-detect macOS, Arch Linux, WSL, or Windows and link managed dotfiles
- `mise run macos`: set up macOS-specific Zsh, Fish, Mise, and VS Code configuration
- `mise run vscode-macos`: link macOS VS Code settings and install declared extensions
- `mise run vim`: link Vim configuration, install vim-plug, and install declared plugins
- `mise run arch`: link Arch Linux-specific Zsh configuration
- `mise run wsl`: link WSL-specific Fish and Mise configuration
- `mise run windows`: copy Windows-specific PowerShell and Windows Terminal configuration
- `mise run pi-config`: install the Pi platform profile and common files; mappings are documented in `tools/pi/manifest.json`
- `mise run clean`: remove only repo-managed symlinks (on Windows, copies that still match the repo)

On macOS and Linux, tasks run in bash and symlink files (`scripts/dotfiles.sh`). On Windows, `run_windows` tasks run in PowerShell 7 (`pwsh`) and copy files instead (`scripts/dotfiles.ps1`): a missing file is copied, and a copy that differs from the repo is reported but never overwritten. The Windows install covers the PowerShell profile (`$PROFILE.CurrentUserCurrentHost`), Windows Terminal settings, pi, and the Claude Code status line; Vim and Neovim are not set up on Windows.

## Managed Paths

These paths are currently managed by `mise.toml` (symlinked on macOS and Linux; `tools/pi/` and `.claude/` sources are copied on Windows):

- `.tmux.conf` -> `~/.tmux.conf`
- `.gitconfig` -> `~/.gitconfig`
- `.zshenv` -> `~/.zshenv`
- `.vimrc` -> `~/.vimrc`
- `.config/nvim/` -> `~/.config/nvim`
- `.config/herdr/config.toml` -> `~/.config/herdr/config.toml`
- `.config/herdr/plugins/config/cloudmanic.herdr-plus` -> `~/.config/herdr/plugins/config/cloudmanic.herdr-plus`
- `.config/ghostty/` -> `~/.config/ghostty`
- `.config/zed/` -> `~/.config/zed`
- `.config/emacs/` -> `~/.config/emacs`
- `.config/starship.toml` -> `~/.config/starship.toml`
- `.config/gh/config.yml` -> `~/.config/gh/config.yml`
- `.config/jj/config.toml` -> `~/.config/jj/config.toml`
- `.config/sqlfluff/` -> `~/.config/sqlfluff/`
- `tools/pi/macos/agent/settings.json` seeds `~/.pi/agent/settings.json` on macOS, Arch, and WSL
- `tools/pi/windows/agent/settings.json` seeds `~/.pi/agent/settings.json` on Windows
- `tools/pi/common/web-search.json` -> `~/.pi/agent/web-search.json` on all platforms
- `tools/pi/common/agent/extensions/statusline.ts` -> `~/.pi/agent/extensions/statusline.ts`
- `tools/pi/common/agent/extensions/openai-fast.ts` -> `~/.pi/agent/extensions/openai-fast.ts`
- `tools/pi/common/agent/extensions/exit.ts` -> `~/.pi/agent/extensions/exit.ts`
- `tools/pi/common/agent/extensions/webfetch.ts` -> `~/.pi/agent/extensions/webfetch.ts`
- `tools/pi/manifest.json` records Pi source-to-destination mappings by platform
- `.claude/statusline.js` -> `~/.claude/statusline.js`
- `.config/fish/macos/config.fish` -> `~/.config/fish/config.fish` on macOS
- `.config/fish/macos/fish_plugins` -> `~/.config/fish/fish_plugins` on macOS
- `.config/mise/macos/config.toml` -> `~/.config/mise/config.toml` on macOS
- `vscode/macos/settings.json` -> `~/Library/Application Support/Code/User/settings.json` on macOS
- `vscode/macos/keybindings.json` -> `~/Library/Application Support/Code/User/keybindings.json` on macOS
- `.config/mise/wsl/config.toml` -> `~/.config/mise/config.toml` on WSL
- `.config/fish/wsl/config.fish` -> `~/.config/fish/config.fish` on WSL
- `zshrc/macos/.zshrc` -> `~/.zshrc` on macOS
- `zshrc/arch-i3/.zshrc` -> `~/.zshrc` on Arch Linux
- `powershell/Microsoft.PowerShell_profile.ps1` copied to `$PROFILE.CurrentUserCurrentHost` on Windows
- `windows_terminal/mnt/.../settings.json` copied to Windows Terminal `settings.json` on Windows

## Layout

- `.tmux.conf`: tmux configuration
- `.gitconfig`: Git configuration
- `.zshenv`: non-interactive-safe Zsh environment and PATH setup
- `.vimrc`: Vim 9.2 configuration managed with vim-plug
- `.config/nvim/`: Neovim configuration
- `.config/herdr/`: Herdr and Herdr Plus configuration
- `.config/ghostty/`: Ghostty terminal configuration
- `.config/zed/`: Zed editor configuration
- `.config/emacs/`: Emacs configuration
- `.config/starship.toml`: Starship prompt configuration
- `.config/gh/config.yml`: GitHub CLI preferences (authentication stays outside the repo)
- `.config/jj/config.toml`: Jujutsu user configuration
- `.config/mise/{macos,wsl}/config.toml`: Platform-specific global Mise tools
- `vscode/macos/`: macOS VS Code settings, keybindings, and extension declarations
- `.config/fish/macos/`: macOS Fish configuration and Fisher plugin declarations
- `.config/fish/wsl/config.fish`: WSL Fish configuration
- `.config/sqlfluff/.sqlfluff`: sqlfluff configuration
- `tools/pi/manifest.json`: Maps sources (relative to `tools/pi/`) to `~/.pi` destinations and platforms; `seed` preserves local settings, while `managed` files are linked on Unix and copied safely on Windows
- `tools/pi/macos/`: Pi settings profile used on macOS, Arch, and WSL
- `tools/pi/windows/`: Windows Pi settings profile
- `tools/pi/common/`: Shared Pi web-search preferences and local extensions (token speed, OpenAI Codex Fast mode, `/exit`, Jina-based `webfetch` tool)
- `.claude/statusline.js`: Claude Code status line (Node); enable with `"statusLine": {"type": "command", "command": "node ~/.claude/statusline.js"}` in `~/.claude/settings.json`
- `zshrc/macos/.zshrc`: macOS Zsh configuration
- `zshrc/arch-i3/.zshrc`: Arch Linux Zsh configuration

## Neovim

Neovim is a compact single-file config using native `vim.pack`.

- `init.lua`: options, keymaps, autocmds, plugins, LSP, completion, and snippets
- `nvim-pack-lock.json`: lockfile managed by `vim.pack`

See `.config/nvim/README.md` for plugin install/remove notes.
See `AGENTS.md` for the repo-wide edit map for automated changes.

## Vim

Vim 9.2 uses vim-plug for `vim-tmux-navigator`; run `mise run vim` to install both.
Use `:RepoDiff` or `<leader>gg` to open the current JJ or Git working-copy diff
in a disposable tab. Pass an optional directory, such as `:RepoDiff .config/nvim`,
to use the nearest repository containing that directory and limit the diff to
that path. Changed files start collapsed; use Vim's standard `z` commands to
reveal a complete file entry, and press `q` to close the tab.

Use `:JjDiff` or `:GitDiff` for explicit revision comparisons. Both accept
no arguments for current working-copy changes, `from REV [directory]` for a
working-copy baseline, `show REV [directory]` for one revision's patch, or
`between REV1 REV2 [directory]` to compare endpoints.
