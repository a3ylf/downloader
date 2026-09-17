//go:build windows

package main

import (
	"context"
	"os"
	"os/exec"
	"testing"
	"time"
)

func TestWindowsHistory(t *testing.T) {
	// Exercise the actual launcher stdin transport and embedded WPF, including
	// two save cycles so already saved titles cannot silently become corrupted.
	self, err := os.Executable()
	if err != nil {
		t.Fatal(err)
	}
	root := t.TempDir()
	for _, mode := range []string{"history-save", "history-save", "history-load", "history-search", "history-navigation", "history-repair"} {
		t.Run(mode, func(t *testing.T) {
			ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
			defer cancel()
			command := exec.CommandContext(ctx, self)
			command.Env = append(os.Environ(),
				"DLR_UI_TEST_LAUNCHER=1",
				"DLR_UI_VALIDATE="+mode,
				"DLR_HISTORY_DIR="+root,
				"DLR_START_MENU_DIR="+root,
			)
			command.WaitDelay = time.Second
			if output, err := command.CombinedOutput(); err != nil {
				t.Fatalf("%s failed: %v\n%s", mode, err, output)
			}
		})
	}
}
