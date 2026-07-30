package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

var version = "0.2.0-dev"

const outputTemplate = "%(title).200B [%(id)s].%(ext)s"

type options struct {
	mp3       bool
	outputDir string
	cookies   string
	quality   int
	version   bool
	ffmpegDir string
	jsRuntime string
	urls      []string
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	opts, err := parseArgs(args)
	if err != nil {
		return err
	}

	if opts.version {
		fmt.Println("dlr", version)
		return nil
	}

	ytDLP, err := findTool("yt-dlp")
	if err != nil {
		return missingToolError("yt-dlp")
	}

	ffmpeg, err := findTool("ffmpeg")
	if err != nil {
		return missingToolError("ffmpeg")
	}
	opts.ffmpegDir = filepath.Dir(ffmpeg)

	if jsRuntime, ok := findJSRuntime(); ok {
		opts.jsRuntime = jsRuntime
	}

	if err := os.MkdirAll(opts.outputDir, 0o755); err != nil {
		return fmt.Errorf("create output directory: %w", err)
	}

	cmd := exec.Command(ytDLP, buildYTDLPArgs(opts)...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Env = os.Environ()

	if opts.mp3 {
		fmt.Println("Downloading and converting to MP3...")
	} else {
		fmt.Println("Downloading video...")
	}

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("yt-dlp failed: %w", err)
	}

	return nil
}

func parseArgs(args []string) (options, error) {
	opts := options{
		outputDir: ".",
	}

	fs := flag.NewFlagSet("dlr", flag.ContinueOnError)
	fs.SetOutput(os.Stderr)
	fs.BoolVar(&opts.mp3, "mp3", false, "download and convert to MP3")
	fs.StringVar(&opts.outputDir, "out", opts.outputDir, "output directory")
	fs.StringVar(&opts.outputDir, "o", opts.outputDir, "output directory")
	fs.StringVar(&opts.cookies, "cookies", "", "cookies file for sites that require login")
	fs.IntVar(&opts.quality, "quality", 0, "maximum video height (480, 720, 1080, 1440, or 2160)")
	fs.BoolVar(&opts.version, "version", false, "print version")
	fs.Usage = usage(fs)

	if err := fs.Parse(normalizeArgs(args)); err != nil {
		return opts, err
	}

	opts.urls = fs.Args()
	if !opts.version && len(opts.urls) == 0 {
		fs.Usage()
		return opts, fmt.Errorf("missing URL")
	}
	if opts.quality != 0 && opts.quality != 480 && opts.quality != 720 &&
		opts.quality != 1080 && opts.quality != 1440 && opts.quality != 2160 {
		return opts, fmt.Errorf("quality must be one of 480, 720, 1080, 1440, or 2160")
	}

	return opts, nil
}

func usage(fs *flag.FlagSet) func() {
	return func() {
		fmt.Fprintf(fs.Output(), `Usage:
  dlr URL [options]
  dlr [options] URL [URL...]

Options:
`)
		fs.PrintDefaults()
		fmt.Fprintf(fs.Output(), `
Examples:
  dlr "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  dlr "https://www.youtube.com/watch?v=dQw4w9WgXcQ" --mp3
  dlr "https://x.com/user/status/123" --cookies cookies.txt
`)
	}
}

func normalizeArgs(args []string) []string {
	valueFlags := map[string]bool{
		"--out":     true,
		"-o":        true,
		"--cookies": true,
		"--quality": true,
	}

	var flags []string
	var positional []string
	for i := 0; i < len(args); i++ {
		arg := args[i]
		if arg == "--" {
			positional = append(positional, args[i+1:]...)
			break
		}
		if strings.HasPrefix(arg, "-") && arg != "-" {
			flags = append(flags, arg)
			name := arg
			if before, _, ok := strings.Cut(arg, "="); ok {
				name = before
			}
			if valueFlags[name] && !strings.Contains(arg, "=") && i+1 < len(args) {
				i++
				flags = append(flags, args[i])
			}
			continue
		}
		positional = append(positional, arg)
	}

	return append(flags, positional...)
}

func buildYTDLPArgs(opts options) []string {
	outputPath := filepath.Join(opts.outputDir, outputTemplate)
	args := []string{
		"--newline",
		"--no-mtime",
		"--no-playlist",
		"--ffmpeg-location", opts.ffmpegDir,
		"--restrict-filenames",
		"--windows-filenames",
		"-o", outputPath,
	}

	if opts.jsRuntime != "" {
		args = append(args, "--js-runtimes", opts.jsRuntime)
	}

	args = append(args, "--remote-components", "ejs:github")

	if opts.cookies != "" {
		args = append(args, "--cookies", opts.cookies)
	}

	if opts.mp3 {
		args = append(args,
			"--extract-audio",
			"--audio-format", "mp3",
			"--audio-quality", "0",
			"--embed-metadata",
		)
	} else {
		args = append(args,
			"--format", videoFormat(opts.quality),
			"--merge-output-format", "mp4",
			"--recode-video", "mp4",
			"--postprocessor-args", "VideoConvertor+ffmpeg:-c:v libx264 -c:a aac -movflags +faststart",
		)
	}

	args = append(args, opts.urls...)
	return args
}

func videoFormat(maxHeight int) string {
	height := ""
	if maxHeight > 0 {
		height = fmt.Sprintf("[height<=%d]", maxHeight)
	}

	return "bv*" + height + "[vcodec^=avc1]+ba[acodec^=mp4a]/" +
		"b" + height + "[vcodec^=avc1][acodec^=mp4a]/" +
		"bv*" + height + "+ba/b" + height
}

func findTool(name string) (string, error) {
	if found, err := exec.LookPath(name); err == nil {
		return found, nil
	}

	candidates := localToolCandidates(name)
	for _, candidate := range candidates {
		if isExecutable(candidate) {
			return candidate, nil
		}
	}

	return "", exec.ErrNotFound
}

func localToolCandidates(name string) []string {
	candidates := []string{}
	names := []string{name}
	if runtime.GOOS == "windows" && filepath.Ext(name) == "" {
		names = append(names, name+".exe")
	}

	if cwd, err := os.Getwd(); err == nil {
		for _, candidateName := range names {
			candidates = append(candidates, filepath.Join(cwd, ".tools", "bin", candidateName))
		}
	}

	if exe, err := os.Executable(); err == nil {
		dir := filepath.Dir(exe)
		for _, candidateName := range names {
			candidates = append(candidates,
				filepath.Join(dir, candidateName),
				filepath.Join(dir, ".tools", "bin", candidateName),
				filepath.Join(filepath.Dir(dir), ".tools", "bin", candidateName),
			)
		}
	}

	return candidates
}

func findJSRuntime() (string, bool) {
	for _, runtime := range []string{"deno", "node", "quickjs", "bun"} {
		path, err := findTool(runtime)
		if err == nil {
			return runtime + ":" + path, true
		}
	}
	return "", false
}

func isExecutable(path string) bool {
	info, err := os.Stat(path)
	if err != nil || info.IsDir() {
		return false
	}
	if runtime.GOOS == "windows" {
		return true
	}
	return info.Mode()&0o111 != 0
}

func missingToolError(name string) error {
	var install string
	if name == "yt-dlp" || name == "ffmpeg" {
		if runtime.GOOS == "windows" {
			install = " Download the Windows portable bundle from GitHub Releases, or place the tool beside dlr.exe."
		} else {
			install = " Run ./scripts/install-tools.sh from this repo to install local copies."
		}
	}
	return fmt.Errorf("%s not found.%s", name, install)
}
