# DLR downloader

DLR downloads a single video or audio track from sites supported by `yt-dlp`,
including YouTube and X/Twitter. It is available as:

- a simple Windows desktop app;
- a command-line app for Windows, Linux, and macOS.

## Windows desktop app

1. Open the repository's [Releases](https://github.com/a3ylf/downloader/releases)
   page.
2. Download `dlr-windows-amd64.zip` from the latest release.
3. Extract the entire ZIP to a folder.
4. Double-click `dlr-gui.exe`.
5. Paste a link, select MP4 or MP3 and the desired video quality, choose the
   output folder, and click **Download**.

Keep all files from the ZIP together. The portable bundle includes `dlr.exe`,
`yt-dlp`, FFmpeg, and Deno, so no separate installation is required.

The Windows app downloads one item at a time and never downloads an entire
playlist. Private, sensitive, or login-gated posts are supported by the CLI
when a cookies file is supplied.

## CLI installation

### Linux source install

```sh
./scripts/install.sh
```

This installs `dlr` into `~/.local/bin` and installs local backend tools into
`.tools/bin` when they are missing. For zsh users, it also adds a `noglob`
alias so unquoted YouTube URLs with `?` work. Prebuilt CLI archives for Linux,
macOS, and Windows are also attached to each GitHub release. The prebuilt
non-Windows archives require `yt-dlp` and `ffmpeg` on `PATH`.

## CLI use

Download one video into the directory where you run the command:

```sh
dlr https://www.youtube.com/watch?v=Kc2gCVwkkrA
```

Convert to MP3:

```sh
dlr https://www.youtube.com/watch?v=Kc2gCVwkkrA --mp3
```

Limit video height:

```sh
dlr https://www.youtube.com/watch?v=Kc2gCVwkkrA --quality 1080
```

URLs that include a playlist still download only the current video. Quote URLs
that contain `&`, escape the `&`, or just keep the `watch?v=...` part.

Video downloads are saved as Windows-friendly MP4 files using H.264 video and
AAC audio when conversion is needed.

Use `--out` only when you want a different output folder:

```sh
dlr "https://www.youtube.com/watch?v=Kc2gCVwkkrA" --mp3 --out ~/Music
```

X/Twitter URLs work through yt-dlp's Twitter extractors. Private, sensitive, or
login-gated posts may need cookies:

```sh
dlr "https://x.com/user/status/123" --cookies cookies.txt
```

## Development

Run the automated checks locally:

```sh
go test -race ./...
go vet ./...
```

Build the Windows applications from any Go-supported host:

```sh
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -o dlr.exe ./cmd/dlr
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="-H windowsgui" -o dlr-gui.exe ./cmd/dlr-gui
```

Pull requests and pushes are tested and cross-compiled by GitHub Actions.
Pushing a tag such as `v0.2.0` creates a GitHub Release with platform archives
and `SHA256SUMS.txt`.
