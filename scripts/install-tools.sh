#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS="$ROOT/.tools"
BIN="$TOOLS/bin"
VENV="$TOOLS/venv"

mkdir -p "$BIN"

echo "Installing yt-dlp..."
python3 -m venv "$VENV"
"$VENV/bin/python" -m pip install --upgrade pip yt-dlp
ln -sf "$VENV/bin/yt-dlp" "$BIN/yt-dlp"

if command -v ffmpeg >/dev/null 2>&1; then
  echo "Using system ffmpeg."
  ln -sf "$(command -v ffmpeg)" "$BIN/ffmpeg"
  if command -v ffprobe >/dev/null 2>&1; then
    ln -sf "$(command -v ffprobe)" "$BIN/ffprobe"
  fi
else
  os="$(uname -s)"
  arch="$(uname -m)"

  if [[ "$os" != "Linux" ]]; then
    echo "ffmpeg was not found. Install ffmpeg with your OS package manager, then rerun this script." >&2
    exit 1
  fi

  case "$arch" in
    x86_64|amd64)
      ffmpeg_url="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
      ;;
    aarch64|arm64)
      ffmpeg_url="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-arm64-static.tar.xz"
      ;;
    *)
      echo "Unsupported architecture for automatic ffmpeg install: $arch" >&2
      exit 1
      ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  echo "Installing static ffmpeg..."
  curl -L "$ffmpeg_url" -o "$tmp/ffmpeg.tar.xz"
  tar -xJf "$tmp/ffmpeg.tar.xz" -C "$tmp"
  ffmpeg_dir="$(find "$tmp" -maxdepth 1 -type d -name 'ffmpeg-*-static' | head -n 1)"
  cp "$ffmpeg_dir/ffmpeg" "$BIN/ffmpeg"
  cp "$ffmpeg_dir/ffprobe" "$BIN/ffprobe"
  chmod +x "$BIN/ffmpeg" "$BIN/ffprobe"
  rm -rf "$tmp"
  trap - EXIT
fi

if command -v deno >/dev/null 2>&1 || command -v node >/dev/null 2>&1 || command -v quickjs >/dev/null 2>&1 || command -v bun >/dev/null 2>&1; then
  echo "Using existing JavaScript runtime for yt-dlp."
else
  os="$(uname -s)"
  arch="$(uname -m)"

  if [[ "$os" != "Linux" ]]; then
    echo "No JavaScript runtime found. YouTube may miss some formats unless you install deno or node." >&2
  else
    case "$arch" in
      x86_64|amd64)
        deno_url="https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip"
        ;;
      aarch64|arm64)
        deno_url="https://github.com/denoland/deno/releases/latest/download/deno-aarch64-unknown-linux-gnu.zip"
        ;;
      *)
        deno_url=""
        ;;
    esac

    if [[ -n "${deno_url:-}" ]] && command -v unzip >/dev/null 2>&1; then
      tmp="$(mktemp -d)"
      trap 'rm -rf "$tmp"' EXIT

      echo "Installing deno for yt-dlp JavaScript support..."
      curl -L "$deno_url" -o "$tmp/deno.zip"
      unzip -q "$tmp/deno.zip" -d "$tmp/deno"
      cp "$tmp/deno/deno" "$BIN/deno"
      chmod +x "$BIN/deno"
      rm -rf "$tmp"
      trap - EXIT
    else
      echo "No JavaScript runtime found. YouTube may miss some formats unless you install deno or node." >&2
    fi
  fi
fi

echo "Installed:"
"$BIN/yt-dlp" --version
"$BIN/ffmpeg" -version | head -n 1
if [[ -x "$BIN/deno" ]]; then
  "$BIN/deno" --version | head -n 1
elif command -v deno >/dev/null 2>&1; then
  deno --version | head -n 1
elif command -v node >/dev/null 2>&1; then
  node --version
fi
