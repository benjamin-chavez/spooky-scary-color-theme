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
