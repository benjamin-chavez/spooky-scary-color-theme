# Spooky Scary Color Theme: Neovim port design

Date: 2026-10-02
Branch: nvim-fork

## Goal

Port the VS Code theme in `themes/Spooky Scary Color Theme-color-theme.json`
to a Neovim colorscheme that paints the same colors for the same tokens, and
that maps the workbench colors onto core Neovim UI groups and onto the plugins
in the author's Neovim config. The port is written fresh. The earlier attempt
in `~/.config/nvim` is ignored entirely.

Success means a machine comparison between VS Code's own tokenizer output and
Neovim's resolved highlights reports no differences other than those listed and
justified in `tools/compare/known-differences.json`.

## Scope

In scope:

- Core Neovim UI groups and diagnostics.
- Legacy Vim syntax groups, so files without a treesitter parser still match.
- Treesitter captures, including language-suffixed captures where VS Code has
  language-specific rules.
- Plugin groups for lualine, bufferline, nvim-tree, telescope, gitsigns,
  nvim-cmp, indent-blankline, which-key, render-markdown and todo-comments.
- A verification harness under `tools/compare/`.
- A second independent port written by a Codex agent, and a reconciliation
  process between the two ports.

Out of scope:

- Semantic token colors. The theme JSON has no `semanticHighlighting` key, so
  VS Code uses TextMate scopes only. The port clears the `@lsp.*` groups so
  treesitter rules win.
- A light variant.
- Terminals without true color support. The entry point requires
  `termguicolors`.

## Layout

```
colors/spooky-scary.lua                 entry point, calls require("spooky-scary").load()
lua/spooky-scary/init.lua               load(): termguicolors, clear, apply modules
lua/spooky-scary/palette.lua            named hex values from the theme JSON, plus blended variants
lua/spooky-scary/groups/editor.lua      core UI groups and diagnostics
lua/spooky-scary/groups/syntax.lua      legacy syntax groups
lua/spooky-scary/groups/treesitter.lua  @captures, links into syntax groups where VS Code is generic
lua/spooky-scary/groups/plugins.lua     plugin groups
lua/lualine/themes/spooky-scary.lua     lualine theme table
tools/compare/                          verification harness
docs/superpowers/specs/                 this document
```

Each groups module returns a plain table from highlight group name to the
spec table accepted by `vim.api.nvim_set_hl`. `init.lua` merges the tables
and applies them in order: editor, syntax, treesitter, plugins.

The repo installs with lazy.nvim as
`{ "rojhanpaydar/spooky-scary-color-theme", branch = "nvim-fork" }`.

## Palette and alpha colors

`palette.lua` names every hex value used by the theme JSON. The names describe
the role in the theme, for example `editorBackground`, `plainText`,
`accentPurple`, `accentGreen`, `stringOrange`.

The theme uses eight-digit hex with alpha for comments (`#9bfa8e91`), editor
selection (`#9a66e92a`), editor group drop background, scrollbar sliders and
the markdown fence punctuation (`#00000050`). Neovim has no alpha for text, so
the palette pre-blends each one over `editor.background` (`#23242b`) using
standard source-over compositing. The blended value is what VS Code paints, so
the harness compares against the blended value.

`tools/compare/check-palette.sh` asserts that every six-digit hex in
`palette.lua` that is not marked as blended appears in the theme JSON.

## Workbench to Neovim mapping

| VS Code key | Neovim groups |
| --- | --- |
| `editor.background`, `editor.foreground` | Normal, NormalNC |
| `editorLineNumber.activeForeground` | CursorLineNr |
| `editorCursor.*` | Cursor, lCursor, TermCursor |
| `editor.selectionBackground` (blended) | Visual, VisualNOS |
| `editor.findMatchBackground` | Search, CurSearch, IncSearch |
| `statusBar.background`, `statusBar.foreground` | StatusLine, StatusLineNC, lualine normal section c |
| `tab.activeBackground`, `tab.activeForeground` | TabLineSel, BufferLineBufferSelected |
| `tab.inactiveBackground` | TabLine, TabLineFill, BufferLineBackground |
| `editorGroupHeader.tabsBackground` | BufferLineFill |
| `menu.background`, `menu.selectionBackground` | Pmenu, PmenuSel, CmpItemMenu, WhichKeyFloat |
| `sideBar.background` | NvimTreeNormal, SignColumn, TelescopeNormal |
| `sideBarSectionHeader.foreground` | NvimTreeRootFolder, TelescopeTitle |
| `focusBorder` | FloatBorder, TelescopeBorder, WinSeparator |
| `editorError.foreground` | DiagnosticError, DiagnosticUnderlineError |
| `textLink.foreground`, `textLink.activeForeground` | Underlined, @markup.link.url |
| `gitDecoration.conflictingResourceForeground` | NvimTreeGitMerge |
| markup inserted, changed, deleted | GitSignsAdd, GitSignsChange, GitSignsDelete, DiffAdd, DiffChange, DiffDelete |

Where the theme sets no value, the port derives a value from the palette with a
one-line comment giving the reason. For example DiagnosticWarn uses the orange
`#fca03f` and DiagnosticHint uses the purple `#894fe0`.

## Token mapping

Every entry in `tokenColors` becomes rows in `syntax.lua` or `treesitter.lua`.
The translation table, scope to capture:

| TextMate scope | Neovim group or capture |
| --- | --- |
| `comment`, `punctuation.definition.comment` | Comment, @comment (italic, blended green) |
| `variable` | Identifier, @variable |
| `variable.parameter` | @variable.parameter |
| `variable.language` | @variable.builtin (italic purple) |
| `keyword`, `storage.type`, `storage.modifier` | Keyword, Statement, Type for storage, @keyword, @keyword.function, @type.qualifier |
| `keyword.control` | Conditional, Repeat, @keyword.conditional, @keyword.repeat, @keyword.return (grey `#afafaf`) |
| `keyword.other`, `keyword.other.unit` | @keyword.operator excluded, @number.unit if present |
| `punctuation` | Delimiter, @punctuation.bracket, @punctuation.delimiter, @punctuation.special |
| `meta.tag`, `punctuation.definition.tag` | @tag.delimiter |
| `entity.name.tag` | Tag, @tag |
| `entity.name.function`, `support.function`, `meta.function-call` | Function, @function, @function.call, @function.method, @function.builtin |
| `constant.numeric`, `constant.language`, `support.constant`, `constant.character` | Number, Boolean, Constant, @number, @boolean, @constant, @constant.builtin, @character |
| `constant.character.escape` | @string.escape (`#89DDFF`) |
| `string` | String, @string |
| `string.regexp` | @string.regexp (`#89DDFF`) |
| `entity.name`, `support.type`, `support.class` | Type, @type, @type.builtin, @module, @constructor (`#FFCB6B`) |
| `support.type` alone | @type.builtin? Note: the later rule `#F17008` overrides `support.type` for exact matches. Resolve by harness. |
| `entity.other.attribute-name` | @tag.attribute (`#C792EA`) |
| `text.html.basic entity.other.attribute-name` | @tag.attribute.html (italic `#fca03f`) |
| `entity.other.attribute-name.class` | @type.css for class selectors (`#c8a9f7`) |
| `source.css support.type.property-name` | @property.css (`#fca03f`) |
| `source.json ... support.type.property-name.json` level 0 | @property.json (`#C792EA`) |
| `markup.heading` | @markup.heading (`#C3E88D`) |
| `markup.italic` | @markup.italic (italic `#f07178`) |
| `markup.bold` | @markup.strong (bold `#fab56b`) |
| `markup.underline` | @markup.underline |
| `markup.quote` | @markup.quote (italic) |
| `string.other.link.title.markdown` | @markup.link.label (`#82AAFF`) |
| `markup.raw.block`, `markup.inline.raw` | @markup.raw.block, @markup.raw (`#C792EA`) |
| `meta.separator` | @punctuation.special.markdown for thematic break (bold `#65737E`) |
| `markup.inserted`, `markup.changed`, `markup.deleted` | @diff.plus, @diff.delta, @diff.minus |
| `invalid` | Error, @error (`#ff7300`) |

The harness decides disputed rows. Where VS Code's TextMate rule ordering
produces a color that this table does not predict, the table changes, not the
harness.

## Known differences

Some TextMate rules have no treesitter equivalent. These are recorded in
`tools/compare/known-differences.json` with a reason each. Expected entries:

- JSON key depth colors for levels 1 through 8. Treesitter has no nesting
  depth in captures. Level 0 color applies to all keys.
- Markdown fenced code block content at `#00000050`, which is near-invisible
  in VS Code and overridden by the later `#EEFFFF` rule. The harness result
  decides which wins.
- Scope boundaries where a TextMate grammar and a treesitter grammar split a
  token differently, for example template string punctuation.

Each entry names the sample file, the line range or token text, the VS Code
color, the Neovim color and the reason. Entries are added only when both the
author and the Codex agent agree the difference is inherent.

## Verification harness

Location: `tools/compare/`, with its own `package.json` depending on
`vscode-textmate` and `vscode-oniguruma`.

- `samples/`: one file per language, covering JS, TS, TSX, HTML, CSS, JSON,
  Markdown, Python and Lua. Each sample exercises the constructs the theme
  colors: comments, strings, escapes, regex, numbers, booleans, keywords,
  control flow, functions and calls, classes and types, tags and attributes,
  properties, headings, emphasis, links, code blocks and lists.
- `vscode-tokens.mjs`: loads the theme JSON and the grammars from
  `/Applications/Visual Studio Code.app/Contents/Resources/app/extensions/*/syntaxes`,
  tokenizes each sample with `tokenizeLine2`, decodes the metadata through the
  registry color map, and writes `out/vscode/<sample>.json` with one record per
  character: foreground hex, bold, italic, underline.
- `nvim-tokens.lua`: run as
  `nvim --headless -u tools/compare/minimal-init.lua -l tools/compare/nvim-tokens.lua`.
  Loads the colorscheme, opens each sample, starts the treesitter highlighter,
  and for each character resolves the winning capture's highlight through
  `vim.api.nvim_get_hl` with links followed. Writes `out/nvim/<sample>.json`
  in the same shape.
- `diff.mjs`: compares the two directories character by character, groups
  runs of identical mismatches into one row showing sample, line, token text,
  VS Code color and Neovim color, and excludes rows matched by
  `known-differences.json`. Exits non-zero when any unexcluded row remains.
- `render.mjs`: writes `out/html/<sample>.html` with the sample painted twice
  side by side, VS Code colors on the left and Neovim colors on the right, for
  screenshots in Chrome.
- `screenshot.sh`: opens VS Code on a sample with `code --goto` and captures
  the window with `screencapture` for a real workbench reference.
- `check-palette.sh`: described in the palette section.
- `run.sh`: installs dependencies if needed, then runs the three steps and
  prints the diff.

## Codex collaboration

1. Create a git worktree for Codex at a sibling directory on a branch named
   `nvim-fork-codex`.
2. Give Codex the same brief as the author received, this spec, and the theme
   JSON. Codex writes its own complete port under the same layout in its
   worktree using `codex exec`.
3. Build the harness in the author's worktree. The harness reads a port by
   path so it can run against either worktree.
4. Reconciliation rounds. Each round:
   - Run the harness against both ports and save both diff outputs.
   - Send Codex a message containing both diff outputs, the author's modules,
     and a list of the author's proposed changes to Codex's port. Ask Codex
     for its critique of the author's modules and for its own proposed
     changes, with reasons tied to specific theme JSON rules.
   - The author reviews Codex's critique against the theme JSON and the
     harness output, applies the changes that are correct, and records the
     rejected ones with a reason.
   - Both sides update their ports. Any newly agreed inherent difference goes
     into `known-differences.json`.
5. Stop when both ports pass the harness with the same `known-differences.json`
   and Codex states in writing that it agrees the port is one to one. Expect
   three to five rounds. The author's port is the deliverable. Codex's
   worktree stays in place until the user removes it.

A `docs/superpowers/specs/2026-10-02-nvim-port-reconciliation.md` log records
each round's agreed and rejected changes.

## Error handling

- The entry point raises a clear error if `termguicolors` cannot be enabled.
- Plugin groups are defined unconditionally. Undefined groups are harmless.
- Files without a treesitter parser fall back to the legacy syntax groups,
  which carry the same colors.
- The harness fails loudly if the VS Code app bundle or a grammar is missing,
  naming the path it looked in.

## Testing

- `tools/compare/run.sh` is the acceptance test and must exit zero.
- `tools/compare/check-palette.sh` must exit zero.
- `nvim --headless -c "colorscheme spooky-scary" -c q` must exit zero with no
  messages.
- Manual: open each sample in the author's real Neovim config and compare to
  the VS Code screenshot from `screenshot.sh`.
