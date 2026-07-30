package main

import (
	"strings"
	"testing"
)

func TestEmbeddedUIContainsCoreControls(t *testing.T) {
	for _, control := range []string{
		`Name="URLInput"`,
		`Name="FormatCombo"`,
		`Name="QualityCombo"`,
		`Name="OutputInput"`,
		`Name="DownloadButton"`,
		`Name="OpenFolderButton"`,
		`Name="ActivityCard"`,
	} {
		if !strings.Contains(uiScript, control) {
			t.Errorf("embedded UI does not contain %s", control)
		}
	}
}

func TestEmbeddedUIUsesGlassVisuals(t *testing.T) {
	for _, visual := range []string{
		"LinearGradientBrush",
		"BlurEffect",
		"DropShadowEffect",
		`CornerRadius="18"`,
	} {
		if !strings.Contains(uiScript, visual) {
			t.Errorf("embedded UI does not contain %s", visual)
		}
	}
}

func TestEmbeddedUIRegistersStartMenuShortcut(t *testing.T) {
	for _, integration := range []string{
		`GetFolderPath('Programs')`,
		`'DLR.lnk'`,
		`$shortcut.TargetPath = $target`,
		`$shortcut.IconLocation = "$target,0"`,
	} {
		if !strings.Contains(uiScript, integration) {
			t.Errorf("embedded UI does not contain %s", integration)
		}
	}
}
