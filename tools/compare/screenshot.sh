#!/usr/bin/env bash
# tools/compare/screenshot.sh <sample>
# Opens the sample in VS Code and captures the screen to out/screens.
set -euo pipefail
cd "$(dirname "$0")"
sample="${1:?usage: screenshot.sh <sample>}"
mkdir -p out/screens
code --goto "samples/$sample:1:1"
sleep 4
open -a "Visual Studio Code"
sleep 1
screencapture -x "out/screens/vscode-$sample.png"
echo "out/screens/vscode-$sample.png"
