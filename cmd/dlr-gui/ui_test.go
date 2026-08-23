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
		`Name="SidebarLogo"`,
		`Name="HeroLogo"`,
	} {
		if !strings.Contains(uiXAML, control) {
			t.Errorf("embedded UI does not contain %s", control)
		}
	}
}

func TestEmbeddedUIUsesSpectrumWaveVisuals(t *testing.T) {
	for _, visual := range []string{
		"LinearGradientBrush",
		"BlurEffect",
		"DropShadowEffect",
		`CornerRadius="18"`,
		`x:Key="WaveStroke"`,
		`Style="{StaticResource ActiveNavButton}"`,
		`Name="VersionText"`,
		`x:Name="PART_Popup"`,
		`TextElement.Foreground="#F5F1FF"`,
	} {
		if !strings.Contains(uiXAML, visual) {
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

func TestEmbeddedUIUsesExecutableIcon(t *testing.T) {
	for _, integration := range []string{
		`ExtractAssociatedIcon($target)`,
		`$window.Icon = $source`,
	} {
		if !strings.Contains(uiScript, integration) {
			t.Errorf("embedded UI does not contain %s", integration)
		}
	}
}

func TestEmbeddedUIExplainsDownloaderFailures(t *testing.T) {
	for _, diagnostic := range []string{
		`HTTP Error 403:\s*Forbidden`,
		`warning: could not update yt-dlp`,
		`DLR checked for a current yt-dlp`,
		`$_ -notmatch 'yt-dlp failed: exit status'`,
	} {
		if !strings.Contains(uiScript, diagnostic) {
			t.Errorf("embedded UI does not contain diagnostic %q", diagnostic)
		}
	}
}
