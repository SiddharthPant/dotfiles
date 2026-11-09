// Command setup-tool syncs the files listed in tools/*/manifest.json between this repo and the
// home folder. Run it from the repo root.
//
// Each manifest names a destinationRoot and a list of files. A file's source starts with the
// platform folder it lives in (common, posix, linux, macos, wsl or windows), which also decides
// where it applies; a source that is a folder syncs every file under it. A destination is relative
// to destinationRoot unless it is absolute. Both may use $NAME or ${NAME} environment variables,
// and $HOME is the home folder on every OS. A manifest with "enabled": false is skipped.
package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"runtime"
	"slices"
	"strings"

	"github.com/aymanbagabas/go-udiff"
)

const usage = `Sync the files listed in tools/*/manifest.json with the home folder.

Usage:
  setup-tool list               list each tool and how many files it has on this OS
  setup-tool diff [tool...]     show how the installed files differ from the repo
  setup-tool install [tool...]  copy repo files that differ into the home folder
  setup-tool pull [tool...]     copy installed files that differ back into the repo

Without tool names, diff, install and pull cover every enabled tool.
`

var errUsage = errors.New("usage")

func main() {
	err := run(os.Args[1:])
	if errors.Is(err, errUsage) {
		fmt.Fprint(os.Stderr, usage)
		os.Exit(2)
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 0 {
		return errUsage
	}
	cmd, names := args[0], args[1:]
	switch cmd {
	case "help", "-h", "--help":
		fmt.Print(usage)
		return nil
	case "list", "diff", "install", "pull":
	default:
		return errUsage
	}

	tools, err := loadTools("tools", currentSystem())
	if err != nil {
		return err
	}
	if cmd == "list" {
		if len(names) > 0 {
			return errUsage
		}
		list(tools)
		return nil
	}
	selected, err := selectTools(tools, names)
	if err != nil {
		return err
	}

	// Two repo files installed to the same place would overwrite each other.
	owner := map[string]string{}
	for _, t := range selected {
		for _, f := range t.files {
			if src, ok := owner[f.home]; ok && src != f.repo {
				return fmt.Errorf("%s is the destination of both %s and %s", f.home, src, f.repo)
			}
			owner[f.home] = f.repo
		}
	}

	failed := 0
	for _, t := range selected {
		for _, f := range t.files {
			src, dst := f.repo, f.home
			if cmd == "pull" {
				src, dst = dst, src
			}
			out, err := syncFile(cmd, src, dst)
			if err != nil {
				fmt.Fprintln(os.Stderr, "error:", err)
				failed++
				continue
			}
			fmt.Print(out)
		}
	}
	if failed > 0 {
		return fmt.Errorf("%d file(s) failed", failed)
	}
	return nil
}

type tool struct {
	name     string
	disabled bool
	files    []file
}

// file pairs a file in the repo with where it is installed.
type file struct {
	repo, home string
}

type manifest struct {
	Schema          string `json:"$schema"`
	Enabled         *bool  `json:"enabled"`
	DestinationRoot string `json:"destinationRoot"`
	Files           []struct {
		Source      string `json:"source"`
		Destination string `json:"destination"`
	} `json:"files"`
}

// loadTools reads every dir/*/manifest.json and resolves the files that apply to sys.
func loadTools(dir, sys string) ([]tool, error) {
	paths, err := filepath.Glob(filepath.Join(dir, "*", "manifest.json"))
	if err != nil {
		return nil, err
	}
	var tools []tool
	for _, path := range paths {
		t, err := loadTool(path, sys)
		if err != nil {
			return nil, fmt.Errorf("%s: %w", path, err)
		}
		tools = append(tools, t)
	}
	return tools, nil
}

func loadTool(path, sys string) (tool, error) {
	toolDir := filepath.Dir(path)
	t := tool{name: filepath.Base(toolDir)}
	data, err := os.ReadFile(path)
	if err != nil {
		return t, err
	}
	var m manifest
	dec := json.NewDecoder(bytes.NewReader(data))
	dec.DisallowUnknownFields()
	if err := dec.Decode(&m); err != nil {
		return t, err
	}
	if m.Enabled != nil && !*m.Enabled {
		t.disabled = true
		return t, nil
	}

	for _, entry := range m.Files {
		platform, _, _ := strings.Cut(entry.Source, "/")
		applies, known := platforms[platform]
		if !known {
			return t, fmt.Errorf("source %q must start with a platform folder such as common/ or macos/", entry.Source)
		}
		if !applies(sys) {
			continue
		}
		// Expanded only for entries that apply, so Windows-only variables need not exist elsewhere.
		dst, err := expand(entry.Destination)
		if err != nil {
			return t, err
		}
		if !filepath.IsAbs(dst) {
			root, err := expand(m.DestinationRoot)
			if err != nil {
				return t, err
			}
			dst = filepath.Join(root, dst)
		}
		src := filepath.Join(toolDir, filepath.FromSlash(entry.Source))
		err = filepath.WalkDir(src, func(path string, d fs.DirEntry, err error) error {
			if err != nil || d.IsDir() {
				return err
			}
			rel, err := filepath.Rel(src, path)
			t.files = append(t.files, file{repo: path, home: filepath.Join(dst, rel)})
			return err
		})
		if err != nil {
			return t, err
		}
	}
	return t, nil
}

// platforms maps each platform folder to the systems it applies to.
var platforms = map[string]func(sys string) bool{
	"common":  func(string) bool { return true },
	"posix":   func(sys string) bool { return sys != "windows" },
	"linux":   func(sys string) bool { return sys == "linux" || sys == "wsl" },
	"macos":   func(sys string) bool { return sys == "macos" },
	"wsl":     func(sys string) bool { return sys == "wsl" },
	"windows": func(sys string) bool { return sys == "windows" },
}

func currentSystem() string {
	switch runtime.GOOS {
	case "windows":
		return "windows"
	case "darwin":
		return "macos"
	}
	if _, ok := os.LookupEnv("WSL_DISTRO_NAME"); ok {
		return "wsl"
	}
	return "linux"
}

// expand replaces $NAME and ${NAME} with environment variables, failing on unset ones so a typo
// cannot install into the wrong folder. $HOME means the home folder even on Windows.
func expand(path string) (string, error) {
	var missing []string
	expanded := os.Expand(path, func(name string) string {
		if name == "HOME" {
			home, err := os.UserHomeDir()
			if err != nil {
				missing = append(missing, name)
			}
			return home
		}
		value, ok := os.LookupEnv(name)
		if !ok {
			missing = append(missing, name)
		}
		return value
	})
	if len(missing) > 0 {
		return "", fmt.Errorf("%s: $%s is not set", path, strings.Join(missing, ", $"))
	}
	return filepath.Clean(expanded), nil
}

// selectTools returns the named tools, or every enabled tool when no names are given.
func selectTools(tools []tool, names []string) ([]tool, error) {
	if len(names) == 0 {
		return slices.DeleteFunc(slices.Clone(tools), func(t tool) bool { return t.disabled }), nil
	}
	var selected []tool
	for _, name := range names {
		i := slices.IndexFunc(tools, func(t tool) bool { return t.name == name })
		switch {
		case i < 0:
			return nil, fmt.Errorf("unknown tool %q", name)
		case tools[i].disabled:
			return nil, fmt.Errorf("tool %q is disabled in its manifest", name)
		case !slices.ContainsFunc(selected, func(t tool) bool { return t.name == name }):
			selected = append(selected, tools[i])
		}
	}
	return selected, nil
}

// list prints every tool with how many files it has on this OS, dimming the ones with none.
func list(tools []tool) {
	width := 0
	for _, t := range tools {
		width = max(width, len(t.name))
	}
	for _, t := range tools {
		line := fmt.Sprintf("%-*s  %d file(s)", width, t.name, len(t.files))
		if t.disabled {
			line = fmt.Sprintf("%-*s  disabled", width, t.name)
		}
		if t.disabled || len(t.files) == 0 {
			line = paint(line, dim)
		}
		fmt.Println(line)
	}
}

// syncFile copies src over dst when they differ, or for diff only describes the difference.
func syncFile(cmd, src, dst string) (string, error) {
	data, err := os.ReadFile(src)
	if err != nil {
		return "", err
	}
	old, err := os.ReadFile(dst)
	exists := err == nil
	if err != nil && !errors.Is(err, fs.ErrNotExist) {
		return "", err
	}

	switch {
	case exists && bytes.Equal(old, data):
		return paint("same", dim) + " " + dst + "\n", nil
	case cmd == "diff" && !exists:
		return paint("new", green) + " " + dst + "\n", nil
	case cmd == "diff":
		return renderDiff(dst, src, string(old), string(data)), nil
	}
	if err := writeFile(dst, data, src); err != nil {
		return "", fmt.Errorf("copy to %s: %w", dst, err)
	}
	verb := "copied"
	if cmd == "pull" {
		verb = "pulled"
	}
	return paint(verb, green) + " " + src + " -> " + dst + "\n", nil
}

// writeFile writes data to a temporary file next to dst and renames it over dst, so a failed
// write leaves dst intact and a symlink at dst is replaced instead of written through. The copy
// gets modeFrom's permissions, which keeps scripts executable.
func writeFile(dst string, data []byte, modeFrom string) error {
	info, err := os.Stat(modeFrom)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0o777); err != nil {
		return err
	}
	tmp := dst + ".setup-tool.tmp"
	err = os.WriteFile(tmp, data, info.Mode().Perm())
	if err == nil {
		// WriteFile applies the mode only to a new file, and then masked by the umask.
		err = os.Chmod(tmp, info.Mode().Perm())
	}
	if err == nil {
		err = os.Rename(tmp, dst)
	}
	if err != nil {
		os.Remove(tmp)
	}
	return err
}

// renderDiff shows how the installed file (old, at dstPath) differs from the repo file (new, at
// srcPath) as a colored unified diff.
func renderDiff(dstPath, srcPath, old, new string) string {
	var out strings.Builder
	for i, line := range strings.SplitAfter(udiff.Unified(dstPath, srcPath, old, new), "\n") {
		text, newline := strings.CutSuffix(line, "\n")
		switch {
		// The ---/+++ headers are the first two lines; later ones can be a deleted "-- comment".
		case i == 0:
			text = paint(text, boldRed)
		case i == 1:
			text = paint(text, boldGreen)
		case strings.HasPrefix(text, "@@"), strings.HasPrefix(text, `\`):
			text = paint(text, dim)
		// A \r would otherwise hide a line-ending change, since the terminal does not draw it.
		case strings.HasPrefix(text, "-"):
			text = paint(strings.ReplaceAll(text, "\r", "␍"), red)
		case strings.HasPrefix(text, "+"):
			text = paint(strings.ReplaceAll(text, "\r", "␍"), green)
		}
		out.WriteString(text)
		if newline {
			out.WriteString("\n")
		}
	}
	return out.String()
}

// ANSI styles for paint.
const (
	dim       = "2"
	red       = "31"
	green     = "32"
	boldRed   = "1;31"
	boldGreen = "1;32"
)

// useColor is true when stdout is a terminal and NO_COLOR is unset.
var useColor = func() bool {
	info, err := os.Stdout.Stat()
	return err == nil && info.Mode()&os.ModeCharDevice != 0 && os.Getenv("NO_COLOR") == ""
}()

func paint(text, style string) string {
	if !useColor || text == "" {
		return text
	}
	return "\x1b[" + style + "m" + text + "\x1b[0m"
}
