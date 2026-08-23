package main

import (
	"bytes"
	"image/png"
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
		`Name="DownloadNavButton"`,
		`Name="HistoryButton"`,
		`Name="HistoryPage"`,
		`Name="HistoryList"`,
		`Name="ClearHistoryButton"`,
	} {
		if !strings.Contains(uiXAML, control) {
			t.Errorf("embedded UI does not contain %s", control)
		}
	}
}

func TestEmbeddedUIStoresDownloadHistoryWithThumbnails(t *testing.T) {
	for _, integration := range []string{
		`DLR_HISTORY_JSON:`,
		`history.json`,
		`LocalApplicationData`,
		`Save-History`,
		`Add-HistoryRecord`,
		`Cache-HistoryThumbnail`,
		`$historyButton.Add_Click`,
	} {
		if !strings.Contains(uiScript, integration) {
			t.Errorf("embedded download history does not contain %q", integration)
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

func TestEmbeddedUIUsesDLRTaskbarIdentityAndIcon(t *testing.T) {
	for _, integration := range []string{
		`SetCurrentProcessExplicitAppUserModelID('DLR.Downloader')`,
		`$window.Icon = $iconBitmap`,
	} {
		if !strings.Contains(uiScript, integration) {
			t.Errorf("embedded UI does not contain %s", integration)
		}
	}
}

func TestEmbeddedLogoArtworkIsCentered(t *testing.T) {
	logo, err := png.Decode(bytes.NewReader(uiIcon))
	if err != nil {
		t.Fatalf("decode embedded logo: %v", err)
	}

	bounds := logo.Bounds()
	minX, minY := bounds.Max.X, bounds.Max.Y
	maxX, maxY := bounds.Min.X-1, bounds.Min.Y-1
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			_, _, _, alpha := logo.At(x, y).RGBA()
			// Ignore near-transparent alpha noise left by PNG encoding; it is not
			// perceptible and does not contribute to the rendered artwork.
			if alpha <= 0x0404 {
				continue
			}
			minX = min(minX, x)
			minY = min(minY, y)
			maxX = max(maxX, x)
			maxY = max(maxY, y)
		}
	}

	if maxX < minX || maxY < minY {
		t.Fatal("embedded logo has no visible pixels")
	}
	if delta := abs((minX + maxX) - (bounds.Min.X + bounds.Max.X - 1)); delta > 1 {
		t.Errorf("logo artwork bounds (%d,%d)-(%d,%d) are horizontally off-center by %.1f px", minX, minY, maxX, maxY, float64(delta)/2)
	}
	if delta := abs((minY + maxY) - (bounds.Min.Y + bounds.Max.Y - 1)); delta > 1 {
		t.Errorf("logo artwork bounds (%d,%d)-(%d,%d) are vertically off-center by %.1f px", minX, minY, maxX, maxY, float64(delta)/2)
	}
}

func abs(value int) int {
	if value < 0 {
		return -value
	}
	return value
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
