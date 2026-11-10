// Command setup-tool syncs the files listed in tools/*/manifest.json between this repo and the
// home folder. Run it from the repo root.
//
// Each manifest names a destinationRoot and a list of files. A file's source starts with the
// platform folder it lives in (common, posix, linux, macos, wsl or windows), which also decides
// where it applies; a source that is a folder syncs every file under it. A destination is relative
// to destinationRoot unless it is absolute. Both may use $NAME or ${NAME} environment variables,
// and $HOME is the home folder on every OS.
package main

import (
	"bytes"
	"encoding/json/v2"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/aymanbagabas/go-udiff"
)

const usage = `Sync the files listed in tools/*/manifest.json with the home folder.

Usage:
  setup-tool diff [tool...]     show how the installed files differ from the repo
  setup-tool install [tool...]  copy repo files that differ into the home folder
  setup-tool pull [tool...]     copy installed files that differ back into the repo

Without tool names, each command covers every tool.
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
	case "diff", "install", "pull":
	default:
		return errUsage
	}

	files, err := loadFiles("tools", names, currentSystem())
	if err != nil {
		return err
	}

	// Two repo files installed to the same place would overwrite each other.
	owner := map[string]string{}
	for _, f := range files {
		if src, ok := owner[f.home]; ok && src != f.repo {
			return fmt.Errorf("%s is the destination of both %s and %s", f.home, src, f.repo)
		}
		owner[f.home] = f.repo
	}

	failed := 0
	for _, f := range files {
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
	if failed > 0 {
		return fmt.Errorf("%d file(s) failed", failed)
	}
	return nil
}

// file pairs a file in the repo with where it is installed.
type file struct {
	repo, home string
}

type manifest struct {
	Schema          string `json:"$schema"`
	DestinationRoot string `json:"destinationRoot"`
	Files           []struct {
		Source      string `json:"source"`
		Destination string `json:"destination"`
	} `json:"files"`
}

// loadFiles resolves the files that apply to sys from dir/<name>/manifest.json for each name, or
// from every manifest when no names are given.
func loadFiles(dir string, names []string, sys string) ([]file, error) {
	if len(names) == 0 {
		names = []string{"*"}
	}
	var files []file
	for _, name := range names {
		pattern := filepath.Join(dir, name, "manifest.json")
		paths, err := filepath.Glob(pattern)
		if err != nil {
			return nil, err
		}
		if len(paths) == 0 {
			return nil, fmt.Errorf("no manifest at %s", pattern)
		}
		for _, path := range paths {
			found, err := loadManifest(path, sys)
			if err != nil {
				return nil, fmt.Errorf("%s: %w", path, err)
			}
			files = append(files, found...)
		}
	}
	return files, nil
}

func loadManifest(path, sys string) ([]file, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var m manifest
	if err := json.Unmarshal(data, &m, json.RejectUnknownMembers(true)); err != nil {
		return nil, err
	}

	var files []file
	for _, entry := range m.Files {
		platform, _, _ := strings.Cut(entry.Source, "/")
		applies, known := platforms[platform]
		if !known {
			return nil, fmt.Errorf("source %q must start with a platform folder such as common/ or macos/", entry.Source)
		}
		if !applies(sys) {
			continue
		}
		// Expanded only for entries that apply, so Windows-only variables need not exist elsewhere.
		dst, err := expand(entry.Destination)
		if err != nil {
			return nil, err
		}
		if !filepath.IsAbs(dst) {
			root, err := expand(m.DestinationRoot)
			if err != nil {
				return nil, err
			}
			dst = filepath.Join(root, dst)
		}
		src := filepath.Join(filepath.Dir(path), filepath.FromSlash(entry.Source))
		err = filepath.WalkDir(src, func(path string, d fs.DirEntry, err error) error {
			if err != nil || d.IsDir() {
				return err
			}
			rel, err := filepath.Rel(src, path)
			files = append(files, file{repo: path, home: filepath.Join(dst, rel)})
			return err
		})
		if err != nil {
			return nil, err
		}
	}
	return files, nil
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
	return paint("copied", green) + " " + src + " -> " + dst + "\n", nil
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
