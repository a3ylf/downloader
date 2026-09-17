//go:build windows

package main

import (
	"archive/zip"
	"bytes"
	"context"
	"crypto/sha256"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"
)

// The test executable doubles as both the installed launcher and its update.
// Running from the destination also exercises Windows' executable file lock.
func TestMain(m *testing.M) {
	switch os.Getenv("DLR_UPDATE_TEST_ROLE") {
	case "launcher":
		script, err := os.ReadFile(os.Getenv("DLR_UPDATE_TEST_SCRIPT"))
		if err == nil {
			uiScript = string(script)
			err = runUI()
		}
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		os.Exit(0)
	case "restarted":
		if err := os.WriteFile(os.Getenv("DLR_UPDATE_TEST_MARKER"), []byte("restarted"), 0600); err != nil {
			os.Exit(1)
		}
		os.Exit(0)
	default:
		os.Exit(m.Run())
	}
}

func TestWindowsUpdateInstallsAndRestarts(t *testing.T) {
	// Use the production functions without opening WPF or querying GitHub.
	// In particular, keep Install-DLRUpdate's real child-process configuration.
	function := func(start, end string) string {
		t.Helper()
		_, tail, ok := strings.Cut(uiScriptTemplate, start)
		if !ok {
			t.Fatalf("missing script section %q", start)
		}
		body, _, ok := strings.Cut(tail, end)
		if !ok {
			t.Fatalf("missing script section terminator %q", end)
		}
		return start + body + "\n"
	}
	script := "$ErrorActionPreference = 'Stop'\n" +
		function("function Quote-NativeArgument", "function Get-UsefulOutput") +
		function("function Install-DLRUpdate", "$script:updateHttpClient") + `
$appDirectory = $env:DLR_APP_DIR
$appVersion = '0.5.2'
$appProcessId = [int] $env:DLR_APP_PID
$window = New-Object PSObject
$window | Add-Member -MemberType ScriptMethod -Name Close -Value {}
$release = [PSCustomObject]@{
    assets = @(
        [PSCustomObject]@{ name = 'dlr-windows-amd64.zip'; browser_download_url = $env:DLR_UPDATE_TEST_URL + '/package' },
        [PSCustomObject]@{ name = 'SHA256SUMS.txt'; browser_download_url = $env:DLR_UPDATE_TEST_URL + '/checksums' }
    )
}
$env:DLR_UPDATE_TEST_ROLE = 'restarted'
Install-DLRUpdate $release
`
	root := t.TempDir()
	destination := filepath.Join(root, "DLR portable with spaces")
	if err := os.Mkdir(destination, 0700); err != nil {
		t.Fatal(err)
	}
	self, err := os.Executable()
	if err != nil {
		t.Fatal(err)
	}
	binary, err := os.ReadFile(self)
	if err != nil {
		t.Fatal(err)
	}
	write := func(path string, data []byte) {
		t.Helper()
		if err := os.WriteFile(path, data, 0600); err != nil {
			t.Fatal(err)
		}
	}
	launcherPath := filepath.Join(destination, "dlr-gui.exe")
	write(launcherPath, binary)
	write(filepath.Join(destination, "dlr.exe"), []byte("old CLI"))
	write(filepath.Join(destination, "keep.txt"), []byte("user file"))
	scriptPath := filepath.Join(root, "test update.ps1")
	write(scriptPath, []byte(script))
	marker := filepath.Join(root, "restarted.txt")

	var archive bytes.Buffer
	zw := zip.NewWriter(&archive)
	for name, data := range map[string][]byte{
		"dlr-gui.exe": binary,
		"dlr.exe":     []byte("new CLI"),
		"yt-dlp.exe":  []byte("new downloader"),
	} {
		file, err := zw.Create("dlr-windows-amd64/" + name)
		if err != nil {
			t.Fatal(err)
		}
		if _, err := file.Write(data); err != nil {
			t.Fatal(err)
		}
	}
	if err := zw.Close(); err != nil {
		t.Fatal(err)
	}
	checksum := fmt.Sprintf("%x  ./dlr-windows-amd64.zip\n", sha256.Sum256(archive.Bytes()))
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/package":
			_, _ = w.Write(archive.Bytes())
		case "/checksums":
			_, _ = fmt.Fprint(w, checksum)
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 45*time.Second)
	defer cancel()
	command := exec.CommandContext(ctx, launcherPath)
	command.Env = append(os.Environ(),
		"DLR_UPDATE_TEST_ROLE=launcher",
		"DLR_UPDATE_TEST_SCRIPT="+scriptPath,
		"DLR_UPDATE_TEST_MARKER="+marker,
		"DLR_UPDATE_TEST_URL="+server.URL,
		"TEMP="+root,
		"TMP="+root,
	)
	// Kill the whole tree on a regression, including the installer waiting on
	// the launcher. Bound the test driver's own output-pipe wait as well.
	command.Cancel = func() error {
		return exec.Command("taskkill.exe", "/F", "/T", "/PID", strconv.Itoa(command.Process.Pid)).Run()
	}
	command.WaitDelay = time.Second
	if output, err := command.CombinedOutput(); err != nil {
		t.Fatalf("launcher did not exit cleanly: %v\n%s", err, output)
	}
	for {
		if _, err := os.Stat(marker); err == nil {
			break
		}
		select {
		case <-ctx.Done():
			t.Fatal("updated application did not restart")
		case <-time.After(100 * time.Millisecond):
		}
	}
	for name, want := range map[string]string{
		"dlr.exe":    "new CLI",
		"yt-dlp.exe": "new downloader",
		"keep.txt":   "user file",
	} {
		got, err := os.ReadFile(filepath.Join(destination, name))
		if err != nil || string(got) != want {
			t.Errorf("installed %s = %q, %v; want %q", name, got, err, want)
		}
	}
}
