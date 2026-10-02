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
SPOOKY_PORT_DIR="$port_dir" SPOOKY_OUT_DIR="$PWD/out/nvim-$label" \
  nvim --headless --clean -l nvim-tokens.lua
node diff.mjs "out/nvim-$label"
