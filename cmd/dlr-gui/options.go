package main

import "strconv"

var videoHeights = []int{0, 1080, 720, 480}

func downloadArgs(formatIndex, qualityIndex int, output, link string) []string {
	args := []string{"--out", output}
	if formatIndex == 1 {
		args = append(args, "--mp3")
	} else if qualityIndex >= 0 && qualityIndex < len(videoHeights) && videoHeights[qualityIndex] > 0 {
		args = append(args, "--quality", strconv.Itoa(videoHeights[qualityIndex]))
	}
	return append(args, link)
}
