#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_BIN="${DLR_INSTALL_BIN:-$HOME/.local/bin}"

mkdir -p "$INSTALL_BIN"

if [[ ! -x "$ROOT/.tools/bin/yt-dlp" || ! -x "$ROOT/.tools/bin/ffmpeg" ]]; then
  "$ROOT/scripts/install-tools.sh"
fi

cd "$ROOT"
go build -o "$INSTALL_BIN/dlr" ./cmd/dlr

ln -sf "$ROOT/.tools/bin/yt-dlp" "$INSTALL_BIN/yt-dlp"
ln -sf "$ROOT/.tools/bin/ffmpeg" "$INSTALL_BIN/ffmpeg"

if [[ -e "$ROOT/.tools/bin/ffprobe" ]]; then
  ln -sf "$ROOT/.tools/bin/ffprobe" "$INSTALL_BIN/ffprobe"
fi

if [[ -e "$ROOT/.tools/bin/deno" ]]; then
  ln -sf "$ROOT/.tools/bin/deno" "$INSTALL_BIN/deno"
fi

echo "Installed dlr to $INSTALL_BIN/dlr"

if [[ "${SHELL:-}" == */zsh ]]; then
  zshrc="$HOME/.zshrc"
  alias_line="alias dlr='noglob dlr'"

  touch "$zshrc"
  if ! grep -Fxq "$alias_line" "$zshrc"; then
    {
      echo
      echo "# Allow unquoted URLs like dlr https://youtube.com/watch?v=..."
      echo "$alias_line"
    } >> "$zshrc"
    echo "Added zsh alias for unquoted URLs. Restart your shell or run: source $zshrc"
  fi
fi

if [[ ":$PATH:" != *":$INSTALL_BIN:"* ]]; then
  echo "Add this to your shell config if dlr is not found:"
  echo "  export PATH=\"$INSTALL_BIN:\$PATH\""
fi
