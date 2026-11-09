package main

import (
	"os"
	"path/filepath"
	"slices"
	"strings"
	"testing"
)

// TestLoadTools checks platform folders, folder sources, variables and disabled manifests.
func TestLoadTools(t *testing.T) {
	dir, home := t.TempDir(), t.TempDir()
	t.Setenv("SETUP_TOOL_TEST_HOME", home)
	write := func(path, data string) {
		t.Helper()
		path = filepath.Join(dir, path)
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, []byte(data), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	for _, path := range []string{"app/common/a.conf", "app/posix/themes/dark.conf", "app/posix/themes/sub/light.conf", "app/windows/b.conf"} {
		write(path, "")
	}
	write("app/manifest.json", `{
		"destinationRoot": "$SETUP_TOOL_TEST_HOME",
		"files": [
			{"source": "common/a.conf", "destination": "a.conf"},
			{"source": "posix/themes", "destination": ".config/themes"},
			{"source": "windows/b.conf", "destination": "$WINDOWS_ONLY_VARIABLE/b.conf"}
		]
	}`)
	write("old/manifest.json", `{"enabled": false, "destinationRoot": "$NOT_SET", "files": []}`)

	tools, err := loadTools(dir, "linux")
	if err != nil {
		t.Fatal(err)
	}
	if len(tools) != 2 || tools[0].name != "app" || !tools[1].disabled {
		t.Fatalf("got tools %+v", tools)
	}
	var got []string
	for _, f := range tools[0].files {
		src, _ := filepath.Rel(dir, f.repo)
		dst, _ := filepath.Rel(home, f.home)
		got = append(got, filepath.ToSlash(src)+" -> "+filepath.ToSlash(dst))
	}
	slices.Sort(got)
	want := []string{
		"app/common/a.conf -> a.conf",
		"app/posix/themes/dark.conf -> .config/themes/dark.conf",
		"app/posix/themes/sub/light.conf -> .config/themes/sub/light.conf",
	}
	if !slices.Equal(got, want) {
		t.Errorf("got %q\nwant %q", got, want)
	}

	if _, err := loadTools(dir, "windows"); err == nil || !strings.Contains(err.Error(), "$WINDOWS_ONLY_VARIABLE is not set") {
		t.Errorf("an unset variable should fail where its entry applies, got %v", err)
	}
}

// TestSyncFile walks one file through diff, install, an unchanged install and a pull back.
func TestSyncFile(t *testing.T) {
	dir := t.TempDir()
	repo, home := filepath.Join(dir, "repo.sh"), filepath.Join(dir, "home", "bin", "script.sh")
	if err := os.WriteFile(repo, []byte("echo hi\n"), 0o755); err != nil {
		t.Fatal(err)
	}
	for _, step := range []struct{ cmd, want string }{
		{"diff", "new "},
		{"install", "copied "},
		{"install", "same "},
	} {
		if out, err := syncFile(step.cmd, repo, home); err != nil || !strings.HasPrefix(out, step.want) {
			t.Fatalf("%s: got %q, %v; want a line starting %q", step.cmd, out, err, step.want)
		}
	}
	if info, err := os.Stat(home); err != nil || info.Mode().Perm()&0o100 == 0 {
		t.Errorf("the copy should stay executable: %v, %v", info, err)
	}

	if err := os.WriteFile(home, []byte("echo bye\n"), 0o755); err != nil {
		t.Fatal(err)
	}
	if out, err := syncFile("diff", repo, home); err != nil || !strings.Contains(out, "\n-echo bye\n+echo hi\n") {
		t.Fatalf("diff: %q, %v", out, err)
	}
	if out, err := syncFile("pull", home, repo); err != nil || !strings.HasPrefix(out, "pulled ") {
		t.Fatalf("pull: %q, %v", out, err)
	}
	if data, _ := os.ReadFile(repo); string(data) != "echo bye\n" {
		t.Errorf("pull should update the repo file, got %q", data)
	}
}

// TestRenderDiffDeletedComment checks that a deleted "-- comment" line, which starts with "---"
// like a file header, is still colored as a deletion.
func TestRenderDiffDeletedComment(t *testing.T) {
	useColor = true
	t.Cleanup(func() { useColor = false })
	out := renderDiff("home", "repo", "a\n-- note\n", "a\n")
	if !strings.Contains(out, "\x1b["+red+"m--- note") {
		t.Errorf("deleted comment is not colored as a deletion:\n%q", out)
	}
}
