#!/usr/bin/env bash
# tools/compare/run.sh [port_dir] [label]
# Tokenizes the samples with VS Code's grammars and with the Neovim port at port_dir,
# then diffs them. Output lands in out/vscode and out/nvim-<label>.
set -euo pipefail
cd "$(dirname "$0")"
port_dir="${1:-$(cd ../.. && pwd)}"
label="${2:-local}"
if [ ! -d node_modules ]; then npm install --no-audit --no-fund; fi
node vscode-tokens.mjs
# The screen inspector reads real rendered cells, so it honors offsets and nocombine. It
# needs a terminal, which a detached tmux session provides even from a non-interactive shell.
# Set SPOOKY_RESOLVER=captures for the faster capture-based resolver instead.
if [ "${SPOOKY_RESOLVER:-screen}" = "screen" ]; then
  session="spooky-compare-$$"
  rm -rf "out/nvim-$label"
  tmux new-session -d -s "$session" -x 170 -y 90 \
    "SPOOKY_PORT_DIR='$port_dir' SPOOKY_SAMPLE_DIR='$PWD/samples' SPOOKY_OUT_DIR='$PWD/out/nvim-$label' \
     nvim --clean -n -i NONE -c 'luafile $PWD/nvim-screen.lua' -c 'qa!' 2> '$PWD/out/nvim-screen-$label.err'"
  while tmux has-session -t "$session" 2>/dev/null; do sleep 0.2; done
  if [ -s "out/nvim-screen-$label.err" ]; then cat "out/nvim-screen-$label.err"; fi
  ls "out/nvim-$label" | sed 's/^/nvim    /'
else
  SPOOKY_PORT_DIR="$port_dir" SPOOKY_OUT_DIR="$PWD/out/nvim-$label" \
    nvim --headless --clean -l nvim-tokens.lua
fi
node diff.mjs "out/nvim-$label"
