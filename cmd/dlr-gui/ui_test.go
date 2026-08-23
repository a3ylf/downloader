package main

import (
	"os"
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
		`Name="UpdateButton"`,
	} {
		if !strings.Contains(uiXAML, control) {
			t.Errorf("embedded UI does not contain %s", control)
		}
	}
}

func TestEmbeddedUIDefaultsToMP3(t *testing.T) {
	want := `<ComboBox Name="FormatCombo" Style="{StaticResource GlassCombo}" SelectedIndex="0"><ComboBoxItem Content="Audio (MP3)"/><ComboBoxItem Content="Video (MP4)"/></ComboBox>`
	if !strings.Contains(uiXAML, want) {
		t.Fatal("format selector does not default to MP3")
	}
	if !strings.Contains(uiXAML, `Name="QualityCombo"`) || !strings.Contains(uiXAML, `IsEnabled="False" Opacity="0.48"`) {
		t.Fatal("video quality selector is not initially disabled for MP3")
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

func TestEmbeddedUIInstallsVerifiedGitHubUpdates(t *testing.T) {
	for _, integration := range []string{
		`https://api.github.com/repos/a3ylf/downloader/releases/latest`,
		`dlr-windows-amd64.zip`,
		`SHA256SUMS.txt`,
		`Get-FileHash -LiteralPath $packagePath -Algorithm SHA256`,
		`Expand-Archive -LiteralPath $packagePath`,
		`Start-DLRUpdateCheck $false`,
	} {
		if !strings.Contains(uiScript, integration) {
			t.Errorf("embedded updater does not contain %s", integration)
		}
	}
}

func TestWindowsLauncherPassesAppProcessID(t *testing.T) {
	mainSource, err := os.ReadFile("main_windows.go")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(mainSource), `"DLR_APP_PID="+strconv.Itoa(os.Getpid())`) {
		t.Fatal("Windows launcher does not pass its process ID to the updater")
	}
}
