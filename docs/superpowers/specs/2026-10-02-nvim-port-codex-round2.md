Round 2 reconciliation review, 2026-10-02.

The reported screen result is confirmed: 22 of 6,985 characters differ, with zero unexplained runs and five known-difference runs. JSON depth and cross-scheme neutrality pass. Agreement is withheld because the new Python call rules misclassify names outside the supplied sample.

This review targets `../spooky-scary-color-theme` on `nvim-fork`, at `8fc2292`, including the implementation commit `7f38507`. I read the reconciliation log's Round 1 decisions, both design amendments, the query changes, the predicate plugin, and the relevant highlight mappings. Measurements use the installed Neovim 0.11.6 and VS Code grammars. File references below refer to that port unless stated otherwise.

**1. The screen measurement reproduces exactly.** I first ran the requested command from the Codex checkout:

```sh
(cd ../spooky-scary-color-theme && tools/compare/run.sh "$PWD" claude)
```

The tmux step failed because the sandbox denied access to `/private/tmp/tmux-501/default`. I then ran the requested fallback:

```sh
(cd ../spooky-scary-color-theme && SPOOKY_RESOLVER=captures tools/compare/run.sh "$PWD" claude)
```

That returned 71 of 6,985 differing characters, 21 unexplained runs, and five known-difference runs, with exit status 1. The extra runs concern the resolver's known offset and style-combination limitations. They do not reproduce on the screen.

The system `script` command successfully supplied a terminal without tmux. From the other checkout, I ran its unchanged screen inspector and comparison:

```sh
SPOOKY_PORT_DIR="$PWD" \
SPOOKY_SAMPLE_DIR="$PWD/tools/compare/samples" \
SPOOKY_OUT_DIR=/tmp/spooky-round2-screen \
NVIM_LOG_FILE=/tmp/spooky-round2-nvim.log \
  script -q /tmp/spooky-round2-terminal.log \
  nvim --clean -n -i NONE \
  -c "luafile $PWD/tools/compare/nvim-screen.lua" -c 'qa!' >/dev/null

node tools/compare/diff.mjs /tmp/spooky-round2-screen
```

The comparison exited zero and reported exactly `22 of 6985 characters differ; 0 unexplained runs, 5 known-difference runs`. The exception file contains exactly the five supplied entries.

**2. Predicate registration is safe through the normal plugin lifecycle, and the depth calculation matches the descendant selectors.** `plugin/spooky-scary.lua:3` guards repeated registration. Registration is independent of the active colorscheme, and switching schemes does not remove the handler. The `all = true` callback receives capture-node lists; each shipped depth pattern captures one key, so selecting its first node is appropriate.

I started Neovim with the port on `runtimepath` in an init file and selected `default`. Before any explicit sourcing in the probe, the predicate was registered and the JSON query evaluated successfully. Sourcing the plugin twice, selecting Spooky Scary, and switching back to `default` also succeeded.

There is a loader requirement: adding the directory to `runtimepath` after startup does not source its plugin automatically. In a fresh `--clean` process, doing only that caused query iteration to fail with `No handler for spooky-json-depth?`. Explicitly running `runtime! plugin/spooky-scary.lua` fixed it. All three current comparison helpers, `nvim-screen.lua`, `nvim-tokens.lua`, and `nvim-captures.lua`, already perform that step before evaluating queries. Thus normal installation and the supplied harness satisfy the requirement; a caller that exposes the queries manually must also load the registration plugin. Query parsing alone is insufficient verification because the missing-handler error occurs during predicate evaluation.

The calculation in `plugin/spooky-scary.lua:21` starts at minus one and counts enclosing `object` nodes. A key in the first object therefore has depth zero. Each further enclosing object adds one; arrays add nothing. This matches the theme's space-separated descendant selectors: array scopes can occur between the required dictionary and dictionary-value scopes. An object inside a root array still starts at level zero.

The rules in `queries/json/highlights.scm:13` select exact depths one through seven. Level eight matches every depth of eight or more. This is correct because the theme has no deeper selector and its level-eight selector continues matching descendants.

I compared three temporary JSON fixtures against the same VS Code tokenizer: an object chain through depth ten, the same chain with two array layers between objects, and a root array containing nested objects. All 225 characters matched without exceptions. Both chains produced these key colors:

| Depth | VS Code and Neovim |
| --- | --- |
| 0 | `#c792ea` |
| 1 | `#90f078` |
| 2 | `#f78c6c` |
| 3 | `#ff5370` |
| 4 | `#c17e70` |
| 5 | `#82aaff` |
| 6 | `#f07178` |
| 7 | `#c792ea` |
| 8, 9, 10 | `#c3e88d` |

The final quote capture keeps key delimiters grey after the depth capture. The root-array fixture `[[{"k0":[[{"k1":1}]]}]]` gave `k0` the level-zero color and `k1` the level-one color.

**3. The five requested Python lines match, but the new call classifier is incomplete.** I inspected their TextMate scope stacks, Treesitter captures, and rendered screen cells.

| `sample.py` line | Confirmed result |
| --- | --- |
| 16 | `super` has `support.type.python` and renders `#f17008` through `@spooky.type.builtin`. `__init__` and the argument `name` remain `#b184dd`. |
| 20 | `@` renders `#afafaf`; `property` renders `#f17008` through the existing builtin decorator capture. |
| 22 | The prefix `f` is `#894fe0`; quotes, interpolation braces, and literal text are `#fca03f`. Both `self` occurrences are italic `#894fe0`, dots are `#afafaf`, and `name` and `_weight` are `#a361ff`. |
| 24 | `@` renders `#afafaf`; `staticmethod` renders `#f17008` through the existing builtin decorator capture. |
| 34 | `RuntimeError` has `support.type.exception.python` and renders `#f17008` through the new private capture. |

I accept `@none.python = { fg = p.editorForeground }` in `lua/spooky-scary/groups/treesitter.lua:219`. The installed Python query puts `@none` on interpolation nodes. Explicitly restoring the foreground gives uncolored member names the theme's `#a361ff`, while the more specific captures retain the colors of `self`, punctuation, and braces. This fixes the interpolation gap identified in Round 1. The decorator matches also confirm that restricting the new rules to calls preserves those existing classifications.

The remaining implementation issue is in `queries/python/highlights.scm:45`. The installed MagicPython grammar uses a fixed builtin-exception list, rather than treating every capitalized name ending in `Error`, `Exception`, or `Warning` as builtin. Its builtin-type list also omits `memoryview`. The new query diverges from both lists.

A temporary fixture containing the following ordinary calls produced these actual screen mismatches:

| Call | VS Code | Neovim |
| --- | --- | --- |
| `Exception()` | `#f17008` | `#b184dd` |
| `Warning()` | `#f17008` | `#b184dd` |
| `CustomError()` | `#b184dd` | `#f17008` |
| `CustomException()` | `#b184dd` | `#f17008` |
| `CustomWarning()` | `#b184dd` | `#f17008` |
| `memoryview()` | `#b184dd` | `#f17008` |

The patterns `^%u%w*Exception$` and `^%u%w*Warning$` require an extra uppercase character before the literal suffix, so they miss the bare builtin names. All three suffix patterns also accept user-defined names absent from the grammar's builtin list. `memoryview` receives the function color in the installed TextMate grammar despite being a Python type.

The same fixture included matching controls: `BaseException()`, `UserWarning()`, `RuntimeError()`, `super()`, `list()`, and `len()`. Across this fixture and the three JSON fixtures, 65 of 362 characters differed in six unexplained runs. These probes were compared without exception entries. The nine original fixtures do not exercise these failures.

The required correction is to align the private call capture with the installed grammar's `builtin-types` and `builtin-exceptions` lists: include bare `Exception` and `Warning`, replace the broad exception suffix patterns with the actual builtin names, and remove `memoryview` from the type override. This can retain the private captures and cross-scheme neutrality. I have not changed the implementation.

**4. I accept all five existing exceptions within the stated scope.** Their text, location, and colors match the actual remaining screen runs.

| Location and text | VS Code | Neovim | Decision |
| --- | --- | --- | --- |
| `sample.lua:9`, `@param` | `#894fe0 italic` | `#679e63 italic` | Accept the missing-parser exception. |
| `sample.lua:9`, `name` | `#ffcb6b italic` | `#679e63 italic` | Accept the missing-parser exception. |
| `sample.lua:9`, `string` | `#f17008 italic` | `#679e63 italic` | Accept the missing-parser exception. |
| `sample.py:26`, `raw\s` | `#89ddff` | `#fca03f` | Accept the raw-string parsing tradeoff. |
| `sample.py:26`, `+` | `#894fe0` | `#fca03f` | Accept the same tradeoff for the quantifier. |

For LuaDoc, `vim.treesitter.language.add("luadoc")` returned no parser, with `No parser for language "luadoc"`; the runtime parser-file lookup was empty. The line receives only comment-related captures. Installing a parser changes the user's Neovim environment and is outside this repository review's scope. I accept retaining these three entries. Parser installation and any needed capture mappings would still require verification before removing them; these differences are not inherently impossible to represent.

For raw strings, I accept the reasoning about an unconditional injection query. Injection queries select child parsers independently of colorscheme selection. Adding a raw-string regex injection on `runtimepath` would expose regex captures under other schemes too. This differs from adding undefined private highlight captures. The installed Python injection query currently targets regex calls on `re`; it does not inject the standalone raw string in this sample. Neovim's installed `runtime/doc/treesitter.txt` documents this behavior under `treesitter-language-injections`.

A conditional integration with appropriate parser refresh handling, or another theme-specific implementation, could be explored later. An injection is not the only theoretically possible implementation. I accept these two entries as a deliberate scope and neutrality tradeoff, and no longer require the raw-string regex implementation proposed in Round 1 for agreement. The 16 LuaDoc characters and six raw-string characters account for all 22 measured differences.

**5. The current queries preserve the default colorscheme in the measured cases.** I rendered fresh processes with `SPOOKY_COLORSCHEME=default`, using an empty directory as `SPOOKY_PORT_DIR` for the baseline and the other checkout for the candidate. Both runs retained the same installed parsers and base queries. The candidate explicitly sourced the predicate plugin, as required by the inspector's late runtime-path addition.

I compared foreground, bold, italic, underline, and strikethrough for every cell, including whitespace, with no known-difference exclusions:

| Comparison | Characters checked | Changed cells |
| --- | --- | --- |
| Default, without versus with the port's queries, nine original samples | 6,985 | 0 |
| Fresh default versus Spooky Scary followed by default, nine original samples | 6,985 | 0 |
| Default, without versus with the queries, added depth/array/call fixtures | 362 | 0 |

The switch check used a temporary copy of the inspector with one additional colorscheme selection before selecting `default`. It confirms that the private highlights and `@none.python` correction do not leave visible residue in these samples.

All ten shipped query files contain only private `@spooky.*` captures and underscore-prefixed helper captures. There are no shipped injection-query files. Comparing the two checkouts' query directories confirmed that the only additions to the adopted queries are the JSON and Python changes reviewed above. The measurements support neutrality for the default scheme across the original fixtures and the added cases; they do not claim exhaustive coverage of every possible third-party colorscheme.

**6. Only this report was added, and nothing was committed.** The probes and their outputs are under `/tmp/spooky-round2`, with the original-sample screen output under `/tmp/spooky-round2-screen`. I removed the single tracked Neovim log line generated by the fallback run. Neither port's implementation, sample fixtures, nor exception file was edited. The other checkout's tracked working tree is clean.

DISAGREEMENT: The Python builtin and exception call rules miss `Exception` and `Warning` and misclassify custom exception names and `memoryview`.
