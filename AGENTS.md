This repo holds personal dotfiles for macOS and Windows.
`setup-tool` (Rust, `crates/setup-tool`) copies each tool's files from `tools/<name>/` into the home folder, as listed in the manifests.
The repo is driven by mise; see `mise.toml` for the tasks and pinned tools.
Let the code do the talking: skip comments that restate a line, and prefer doc comments that explain why.
Get approval before running destructive commands, such as `setup-tool` without `-d`, `--pull`, or `mise run install`.
Commit messages are a single-line subject with no co-author trailers.
