package main

import (
	"reflect"
	"strings"
	"testing"
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
