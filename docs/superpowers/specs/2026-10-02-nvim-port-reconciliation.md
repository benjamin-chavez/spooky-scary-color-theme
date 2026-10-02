# Reconciliation log

Two ports were written from the same brief: the author's on `nvim-fork` and
Codex's on `nvim-fork-codex` in the sibling worktree. The harness in
`tools/compare/` is the arbiter. Numbers are "characters differing of 6985"
across the nine samples, with whitespace ignored.

## Round 0: independent ports

| Port | Differing characters | Unexplained runs |
| --- | --- | --- |
| Author, group mapping only | 2012 | 664 |
| Codex, group mapping only | 1442 | 533 |
| Author after per-language capture fixes | 1213 | 424 |
| Author after query extensions | 335 | 96 |
| Author with provisional known differences | 324 | 0 of 93 |

Both ports failed in the same places. The structural buckets were string quote
marks, `meta.block` variables, `meta.brace` brackets, Markdown prose, TypeScript
type punctuation, Python call arguments and JSON key depth. Codex's notes
independently proposed query extensions for them. The author built them; see the
spec amendment.

Codex could not commit from its sandbox because the worktree's index lives in
the parent repository's `.git`, so the author committed its work as
"Codex independent port (round 0)".

The 51 entries in `tools/compare/known-differences.json` are provisional until
Codex reviews them in round 1.

## Round 1

Codex's report is `docs/superpowers/specs/2026-10-02-nvim-port-codex-round1.md`
in its worktree. It ended with DISAGREEMENT, naming JSON key depth as the
largest remaining issue, and brought its own port to 73 differing characters.

### Agreed changes, applied to the author's port

- Replace every sub-capture name in `queries/` with private `@spooky.*`
  captures. Codex measured 446 changed characters under the default
  colorscheme with the old names. The author's neutrality claim was wrong.
- Adopt Codex's query files, which use `#offset!` ranges and `nocombine` to
  fix 46 of the 51 provisional known differences: Python string prefixes,
  f-string quotes, decorator markers, comprehension operators, parameter
  `self`, HTML entity punctuation and the doctype attribute, JSON escaped
  quotes and `\u` escapes, Lua method receivers and library dots, Markdown
  heading markers, title quotes, image descriptions, reference labels, fence
  delimiters, autolink angles, thematic breaks, nested emphasis styles,
  TypeScript `this` type and JSX call parentheses.
- Adopt `tools/compare/nvim-screen.lua` as the default resolver. The
  capture-based resolver ignores `#offset!` and `nocombine`.
- `Visual` takes `editor.selectionForeground`; `Cursor` uses the literal
  cursor colors; `CurSearch` takes `editor.findMatchBackground` and `Search`
  the VS Code default match highlight.
- render-markdown headings gold without bold, inline code pale, bullets and
  quote markers grey, checked tasks blue, table heads without bold.
- Generic `@character.special` is orange (`constant.character`), not the
  escape cyan.
- `console`, `document`, `window` are plain variables; only `this`, `super`
  and `arguments` are language variables.
- Class bodies are not `meta.block`; only statement blocks, named imports and
  export clauses are.

### Rejected or amended claims

- Codex left JSON depth unimplemented and called it the largest issue. The
  author implemented it with the `spooky-json-depth?` predicate registered
  from `plugin/spooky-scary.lua`, which counts enclosing `object` nodes and
  clamps at level 8. All three sample depths now match.
- Codex proposed a regex injection for Python raw strings. Injection queries
  apply under every colorscheme, so this stays a known difference.
- Codex proposed installing the luadoc parser. That is an environment change
  outside the repo, so LuaDoc stays a known difference with that note.
- Codex's f-string interpolation handling left unscoped names string-orange.
  The author sets `@none.python` to the editor foreground.
- Python builtin types and exceptions in call position: Codex proposed but
  did not implement it. The author added `@spooky.type.builtin` rules for the
  grammar's builtin type list and `*Error`, `*Exception`, `*Warning` names.

### Result

| Port | Differing characters | Unexplained runs | Known-difference runs |
| --- | --- | --- | --- |
| Author, round 0 end | 324 | 0 | 93 |
| Codex, round 1 end (own screen check) | 73 | 0 | 13 |
| Author, round 1 end (screen resolver) | 22 | 0 | 5 |

The known-differences file now has five entries: three LuaDoc tokens and two
raw-string regex tokens.
