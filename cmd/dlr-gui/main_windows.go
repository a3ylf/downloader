//go:build windows

package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"
	"unsafe"
)

var version = "0.3.0-dev"

var (
	user32         = syscall.NewLazyDLL("user32.dll")
	procMessageBox = user32.NewProc("MessageBoxW")
)

func main() {
	runtime.LockOSThread()

	if err := runUI(); err != nil {
		messageBox("DLR could not open the desktop interface.\n\n" + err.Error())
	}
}

func runUI() error {
	appDir, err := executableDir()
	if err != nil {
		return err
	}

	powerShell, err := windowsPowerShell()
	if err != nil {
		return err
	}

	command := exec.Command(
		powerShell,
		"-NoLogo",
		"-NoProfile",
		"-NonInteractive",
		"-ExecutionPolicy", "Bypass",
		"-STA",
		"-Command", "-",
	)
	command.Stdin = strings.NewReader(uiScript)
	command.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
	command.Env = append(os.Environ(),
		"DLR_APP_DIR="+appDir,
		"DLR_APP_VERSION="+version,
	)

	var output bytes.Buffer
	command.Stdout = &output
	command.Stderr = &output

	if err := command.Run(); err != nil {
		details := strings.TrimSpace(output.String())
		if details != "" {
			return fmt.Errorf("%w\n\n%s", err, details)
		}
		return err
	}
	return nil
}

func executableDir() (string, error) {
	executable, err := os.Executable()
	if err != nil {
		return "", fmt.Errorf("find application folder: %w", err)
	}
	return filepath.Dir(executable), nil
}

func windowsPowerShell() (string, error) {
	if systemRoot := os.Getenv("SystemRoot"); systemRoot != "" {
		candidate := filepath.Join(systemRoot, "System32", "WindowsPowerShell", "v1.0", "powershell.exe")
		if info, err := os.Stat(candidate); err == nil && !info.IsDir() {
			return candidate, nil
		}
	}
	if found, err := exec.LookPath("powershell.exe"); err == nil {
		return found, nil
	}
	return "", fmt.Errorf("Windows PowerShell was not found")
}

func messageBox(text string) {
	message := utf16(text)
	title := utf16("DLR Downloader")
	procMessageBox.Call(
		0,
		uintptr(unsafe.Pointer(message)),
		uintptr(unsafe.Pointer(title)),
		0x10,
	)
}

func utf16(value string) *uint16 {
	result, err := syscall.UTF16PtrFromString(value)
	if err != nil {
		panic(err)
	}
	return result
}
