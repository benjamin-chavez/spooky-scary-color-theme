#!/usr/bin/env bash
# Regenerates assets/ghost from the README's ghost GIF. Needs ffmpeg.
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"
curl -sL -o "$tmp/ghost.gif" "https://media.giphy.com/media/WngnWxxekMn8DIqmwQ/giphy.gif"
find assets/ghost -name '*.png' -delete
ffmpeg -v error -y -i "$tmp/ghost.gif" -vf "format=rgba,crop=176:240:136:0,scale=-1:192:flags=lanczos" assets/ghost/frame-%02d.png
ls assets/ghost/*.png | wc -l
