package main

import (
	"path/filepath"
	"reflect"
	"strings"
	"testing"
	"time"
)

func TestParseArgsAcceptsOptionsAfterURL(t *testing.T) {
	opts, err := parseArgs([]string{
		"https://example.com/video",
		"--mp3",
		"--quality", "720",
		"--out", "downloads",
	})
	if err != nil {
		t.Fatal(err)
	}

	if !opts.mp3 {
		t.Fatal("mp3 was false")
	}
	if opts.quality != 720 {
		t.Fatalf("quality = %d, want 720", opts.quality)
	}
	if opts.outputDir != "downloads" {
		t.Fatalf("outputDir = %q, want downloads", opts.outputDir)
	}
	if !reflect.DeepEqual(opts.urls, []string{"https://example.com/video"}) {
		t.Fatalf("urls = %#v", opts.urls)
	}
}

func TestParseArgsRejectsUnsupportedQuality(t *testing.T) {
	_, err := parseArgs([]string{"--quality", "123", "https://example.com/video"})
	if err == nil || !strings.Contains(err.Error(), "quality must be one of") {
		t.Fatalf("error = %v, want quality validation error", err)
	}
}

func TestVideoFormat(t *testing.T) {
	tests := []struct {
		name    string
		quality int
		want    string
	}{
		{
			name:    "best",
			quality: 0,
			want:    "bv*[vcodec^=avc1]+ba[acodec^=mp4a]/b[vcodec^=avc1][acodec^=mp4a]/bv*+ba/b",
		},
		{
			name:    "1080p",
			quality: 1080,
			want:    "bv*[height<=1080][vcodec^=avc1]+ba[acodec^=mp4a]/b[height<=1080][vcodec^=avc1][acodec^=mp4a]/bv*[height<=1080]+ba/b[height<=1080]",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := videoFormat(tt.quality); got != tt.want {
				t.Fatalf("videoFormat(%d) = %q, want %q", tt.quality, got, tt.want)
			}
		})
	}
}

func TestBuildYTDLPArgsForMP3(t *testing.T) {
	args := buildYTDLPArgs(options{
		mp3:       true,
		outputDir: "music",
		ffmpegDir: "tools",
		urls:      []string{"https://example.com/video"},
	})
	joined := strings.Join(args, " ")

	for _, expected := range []string{"--extract-audio", "--audio-format mp3", "--no-playlist"} {
		if !strings.Contains(joined, expected) {
			t.Errorf("args %q do not contain %q", joined, expected)
		}
	}
}

func TestLocalToolCandidatesComeBeforePathLookup(t *testing.T) {
	candidates := localToolCandidates("yt-dlp")
	if len(candidates) == 0 {
		t.Fatal("localToolCandidates returned no candidates")
	}
	if !strings.Contains(candidates[0], filepath.Join(".tools", "bin", "yt-dlp")) {
		t.Fatalf("first candidate = %q, want repository-local tool", candidates[0])
	}
}

func TestYTDLPUpdateCheckExpiresAfterOneDay(t *testing.T) {
	t.Setenv("XDG_CACHE_HOME", t.TempDir())
	now := time.Date(2026, time.August, 23, 12, 0, 0, 0, time.UTC)

	if !ytDLPUpdateDue(now) {
		t.Fatal("update was not due with no previous check")
	}
	markYTDLPUpdateChecked(now)
	if ytDLPUpdateDue(now.Add(23 * time.Hour)) {
		t.Fatal("update was due less than one day after previous check")
	}
	if !ytDLPUpdateDue(now.Add(25 * time.Hour)) {
		t.Fatal("update was not due more than one day after previous check")
	}
}
