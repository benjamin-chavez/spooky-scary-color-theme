Round 3 reconciliation review, 2026-10-02.

The Round 2 Python call disagreement is resolved. Both requested screen comparisons pass, and no further issue blocks agreement within the reviewed scope and the five previously accepted exceptions.

This review targets `../spooky-scary-color-theme` on `nvim-fork`, with the Python fix in `78ee637`. During verification, that checkout advanced to `d0ae0d6`, whose only change is `README.md`; the implementation and comparison tools remained unchanged. Measurements use Neovim 0.11.6 and freshly generated output from the installed VS Code grammars. Commands below ran from the other checkout.

**1. The original Round 2 Python call fixture has zero mismatches.** I reused `/tmp/spooky-round2/reference/tools/compare/samples/calls.py` unchanged through a symlink in `/tmp/spooky-round3/reference/tools/compare/samples`. It contains all twelve original calls, including `CustomException()` and `CustomWarning()`. The temporary reference directory contains unchanged copies of the other port's `vscode-tokens.mjs` and `diff.mjs`, with symlinks to its theme and installed dependencies. No known-difference file is present in that directory.

```sh
node /tmp/spooky-round3/reference/tools/compare/vscode-tokens.mjs

SPOOKY_PORT_DIR="$PWD" \
SPOOKY_SAMPLE_DIR=/tmp/spooky-round3/reference/tools/compare/samples \
SPOOKY_OUT_DIR=/tmp/spooky-round3/calls-screen \
NVIM_LOG_FILE=/tmp/spooky-round3/calls-nvim.log \
  script -q /tmp/spooky-round3/calls-terminal.log \
  nvim --clean -n -i NONE \
  -c "luafile $PWD/tools/compare/nvim-screen.lua" -c 'qa!' >/dev/null

node /tmp/spooky-round3/reference/tools/compare/diff.mjs \
  /tmp/spooky-round3/calls-screen
```

The comparison exited zero and reported exactly `0 of 137 characters differ; 0 unexplained runs, 0 known-difference runs`. The actual screen cells confirm these call-name colors:

| Call | VS Code | Neovim screen |
| --- | --- | --- |
| `Exception()` | `#f17008` | `#f17008` |
| `Warning()` | `#f17008` | `#f17008` |
| `CustomError()` | `#b184dd` | `#b184dd` |
| `CustomException()` | `#b184dd` | `#b184dd` |
| `CustomWarning()` | `#b184dd` | `#b184dd` |
| `memoryview()` | `#b184dd` | `#b184dd` |
| `BaseException()` | `#f17008` | `#f17008` |
| `UserWarning()` | `#f17008` | `#f17008` |
| `RuntimeError()` | `#f17008` | `#f17008` |
| `super()` | `#f17008` | `#f17008` |
| `list()` | `#f17008` | `#f17008` |
| `len()` | `#b184dd` | `#b184dd` |

All six previously failing calls and all six controls match. The comparison covers every character of each call, including its parentheses.

**2. The nine original samples reproduce the reported result.** After the Python fixture passed, I regenerated their VS Code reference output and ran the same unchanged screen inspector:

```sh
node tools/compare/vscode-tokens.mjs

SPOOKY_PORT_DIR="$PWD" \
SPOOKY_SAMPLE_DIR="$PWD/tools/compare/samples" \
SPOOKY_OUT_DIR=/tmp/spooky-round3/samples-screen \
NVIM_LOG_FILE=/tmp/spooky-round3/samples-nvim.log \
  script -q /tmp/spooky-round3/samples-terminal.log \
  nvim --clean -n -i NONE \
  -c "luafile $PWD/tools/compare/nvim-screen.lua" -c 'qa!' >/dev/null

node tools/compare/diff.mjs /tmp/spooky-round3/samples-screen
```

The comparison exited zero and reported exactly `22 of 6985 characters differ; 0 unexplained runs, 5 known-difference runs`. The five actual screen differences remain:

| Location and text | VS Code | Neovim screen |
| --- | --- | --- |
| `sample.lua:9`, `@param` | `#894fe0 italic` | `#679e63 italic` |
| `sample.lua:9`, `name` | `#ffcb6b italic` | `#679e63 italic` |
| `sample.lua:9`, `string` | `#f17008 italic` | `#679e63 italic` |
| `sample.py:26`, `raw\s` | `#89ddff` | `#fca03f` |
| `sample.py:26`, `+` | `#894fe0` | `#fca03f` |

These are the same accepted differences from Round 2: sixteen LuaDoc characters due to the missing parser and six Python raw-string regex characters under the accepted parsing tradeoff. The exception file is unchanged.

**3. No further issue blocks agreement.** The exact-name Python rules resolve the sole outstanding Round 2 disagreement. The inspector evidence above introduces no new unexplained runs. The Round 2 acceptance of JSON depth handling, predicate registration, interpolation coloring, cross-scheme neutrality, and the five known differences stands.

**4. Only this report was added, and I made no commit.** Neither port's implementation, sample fixtures, nor exception file was edited. Fresh probe output, terminal logs, and comparison summaries are under `/tmp/spooky-round3`. The other checkout's working tree is clean.

AGREEMENT: the ports are one-to-one with the theme
