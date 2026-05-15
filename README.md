# downloader

Small Go CLI for downloading a single video from YouTube or X/Twitter. It uses
`yt-dlp` for site extraction and `ffmpeg` for MP3 conversion.

## Install

```sh
./scripts/install.sh
```

This installs `dlr` into `~/.local/bin` and installs local backend tools into
`.tools/bin` when they are missing. For zsh users, it also adds a `noglob`
alias so unquoted YouTube URLs with `?` work.

## Use

Download one video into the directory where you run the command:

```sh
dlr https://www.youtube.com/watch?v=Kc2gCVwkkrA
```

Convert to MP3:

```sh
dlr https://www.youtube.com/watch?v=Kc2gCVwkkrA --mp3
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
