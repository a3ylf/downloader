package main

import (
	"reflect"
	"testing"
)

func TestDownloadArgs(t *testing.T) {
	tests := []struct {
		name         string
		formatIndex  int
		qualityIndex int
		want         []string
	}{
		{
			name:         "best video",
			formatIndex:  0,
			qualityIndex: 0,
			want:         []string{"--out", "C:\\Downloads", "https://example.com/video"},
		},
		{
			name:         "1080p video",
			formatIndex:  0,
			qualityIndex: 1,
			want:         []string{"--out", "C:\\Downloads", "--quality", "1080", "https://example.com/video"},
		},
		{
			name:         "mp3 ignores video quality",
			formatIndex:  1,
			qualityIndex: 2,
			want:         []string{"--out", "C:\\Downloads", "--mp3", "https://example.com/video"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := downloadArgs(tt.formatIndex, tt.qualityIndex, "C:\\Downloads", "https://example.com/video")
			if !reflect.DeepEqual(got, tt.want) {
				t.Fatalf("downloadArgs() = %#v, want %#v", got, tt.want)
			}
		})
	}
}
