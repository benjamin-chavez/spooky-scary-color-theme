#!/usr/bin/env bash
# Every opaque hex literal in the palette must appear in the theme JSON.
set -euo pipefail
cd "$(dirname "$0")/../.."
theme="themes/Spooky Scary Color Theme-color-theme.json"
status=0
while read -r hex; do
  if ! grep -qi -- "$hex" "$theme"; then
    echo "not in theme JSON: $hex"
    status=1
  fi
done < <(grep -oE '"#[0-9a-fA-F]{6}"' lua/spooky-scary/palette.lua | tr -d '"' | sort -u)
exit $status
