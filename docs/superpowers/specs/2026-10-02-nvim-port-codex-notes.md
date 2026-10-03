Codex port mapping notes, 2026-10-02.

The independent port is in the eight Lua files specified by the brief. It uses
`themes/Spooky Scary Color Theme-color-theme.json` as its only color source.
I read all thirteen requested query files, including the inherited ecma, jsx
and html_tags queries. I also inspected the bundled VS Code grammars for
JavaScript, TypeScript, HTML, CSS, Markdown, Python and Lua, and the installed
plugins' highlight APIs. I did not inspect another colorscheme or the user's
Neovim configuration.

The comparison harness is not present in this worktree. The decisions below
need reconciliation against tokenizer output before the port can be described
as one to one. I have not created an exception list or declared any difference
inherent. Several differences could be fixed by extending queries once that
work is agreed. This port defines highlights without changing installed queries.

All alpha colors use `floor(source * alpha + background * (1 - alpha) + 0.5)`
per channel, with alpha divided by 255 and background `#23242b`.

| Source | Blended value | Use |
| --- | --- | --- |
| `#9bfa8e91` | `#679e63` | Comments, with italics. |
| `#9a66e92a` | `#372f4a` | Editor selection. |
| `#90f07823` | `#324036` | The editor drop surface, reused for multiple Telescope selections. |
| `#90f078cb` | `#7ac668` | Active scrollbar thumb. |
| `#00000050` | `#18191e` | Markdown fence punctuation where a distinct group is available. |

The palette retains the source values as well as the blends. The shorthand
`editorGroup.border` value `#ffff` is opaque white. Bufferline separators use
the existing six-digit `#ffffff` value. Editor window separators use
`focusBorder`, following the design spec's explicit mapping.

These token decisions required judgment about rule precedence or capture scope.

| Decision | Choice and reason | What remains uncertain |
| --- | --- | --- |
| Unmatched tokens | `Normal` and `SpookyPlainText` use `#a361ff`. This is the editor foreground. | Queries can assign a role to a token that TextMate leaves unscoped. The Python overrides address a clear example, but the harness must find others. |
| Storage versus named types | `Type`, `@type`, `@module` and ordinary constructors use `#FFCB6B`. Storage declarations, modifiers and type keywords use `#894fe0`. | Legacy syntax's single `Type` group cannot distinguish named entities from storage words in every language. |
| Builtin types | `@type.builtin` uses `#F17008`. The later Entity Types rule wins for `support.type`; `support.class` remains gold. | The ecma builtin capture includes classes such as `Promise`, and the Python query includes both types and exceptions. A shared builtin capture cannot always distinguish `support.class`, `support.type`, and the more specific gold `support.type.sys-types`. |
| Operators | Operators use `#894fe0`, while control flow and punctuation use `#afafaf`. The Operator, Misc rule names `keyword.control`, not `keyword.operator`. | A query can combine operators and punctuation under one capture. TypeScript union and intersection operators currently follow its punctuation capture. |
| Imports and directives | Generic imports and directives use the orange `keyword.other` color. JavaScript, TypeScript, TSX and Python imports use grey because their grammars have `keyword.control.import`. CSS at-rules also use grey. | TypeScript's captured `require` and JavaScript's captured `use strict` do not necessarily share the other tokens' TextMate scopes. JavaScript also shares its directive capture between strings and shebangs. |
| Mixed keyword captures | Coroutine keywords use control-flow grey, and ordinary keywords use purple. | The ecma query combines `async` with `await`, and its generic keyword capture combines storage words with `break`, `with` and other control words. Python's generic keyword capture also mixes roles. A language suffix cannot separate tokens within those captures. |
| Block variables | `SpookyBlockVariable` preserves `#d8d8d8`, but ordinary variables stay green. | No installed capture distinguishes `meta.block variable.other` from variables outside blocks. Applying white to all variables would also recolor the outer declarations. This descendant rule needs context-specific query work. |
| Parameters and members | Parameters use orange, and ordinary members and properties use green. Python has its own member override. | References to parameters are often captured as ordinary variables. TextMate object keys can have `constant.other.key`, and inherited classes can take the orange string rule, while Treesitter uses the same member or type capture as other constructs. |
| JavaScript method names | Generic method definitions and calls use `#b184dd`. Separate `SpookyJsMethod` and `SpookyJsConstructor` groups retain the source's italic and upright blue variants. | The current bundled grammar did not expose the older `entity.name.method.js` or `meta.class-method.js` selectors. Its method capture also covers object methods and assignments. I did not apply those older selectors to every method or constructor. |
| JavaScript modules and object keys | Generic modules remain gold, and properties remain green. `SpookyJsModule` retains the source's `#FF5370` variant. | The theme's module, imported-parameter, class-variable and ES7 object-key selectors do not have distinct installed captures. The ES7 rule also adds italics, while the more specific braced object-key selector uses orange. |
| JavaScript decorators | `@attribute.javascript` uses italic `#82AAFF`, following the theme's explicit Decorators rule. | The bundled grammar now uses `meta.decorator.js`, not the theme's `tag.decorator.js` ancestor. Its expression scopes may make this rule inactive. The query also gives the `@` marker and the name the same capture. This mapping is provisional. |
| Language variables | `@variable.builtin` uses italic purple for the theme's `variable.language` rule. | The ecma capture mixes `this`, `super` and `arguments` with `console`, `module`, `window` and `document`. Those globals can have other TextMate scopes. |
| Heuristic constants | Generic constants use orange. Python uppercase identifiers use plain purple, and Lua uppercase identifiers use variable green. | The ecma uppercase-name heuristic does not guarantee a TextMate constant scope. Lua `_VERSION` shares a builtin capture with `nil`, so that narrower capture remains orange. |
| Python ordinary names | Ordinary Python variables, members and imported module names use plain purple. The inspected grammar supplies no general variable scope for those names. | A surrounding `meta.function-call` can color otherwise unscoped argument text purple `#b184dd`. The same Treesitter identifier capture occurs outside those calls. |
| Python calls and decorators | Calls, constructors and decorators use the function color. F-string conversion markers use keyword purple. | The Python builtin-function query also captures type calls such as `str`, which TextMate can classify as orange `support.type`. Decorator punctuation is captured with its name. `__init__` definitions and uppercase class calls share `@constructor`. |
| Python documentation strings | Documentation strings use the string color. Python and Lua shebang captures use blended italic comment green. | Prefixes and delimiters within Python strings have their own TextMate scopes. The installed string capture covers the whole string unless a child capture overrides it. |
| Lua functions and libraries | Lua function keywords use grey. Library prefixes and the `coroutine` capture use the function color, reflecting `support.function.library.lua`. Table constructors use punctuation grey. | Standalone library names can be ordinary green variables. Lua's generic keyword capture combines purple `local` with grey `in`, `goto`, `do`, `end` and `break`. Its punctuation captures also combine tokens the TextMate grammar treats as operators, punctuation or unscoped text. |
| HTML attributes | `@tag.attribute.html` uses italic orange. JSX attributes retain the generic attribute purple. | The HTML descendant selector requires `text.html.basic`. Other HTML-derived languages may need separate overrides once their scope stacks are known. |
| HTML and JSX contents | Presentation-tag contents use plain purple, even when the query calls them headings, emphasis, code or link labels. Ordinary HTML and JSX URL attribute values remain orange strings. | These queries describe rendered meaning that the HTML TextMate grammar does not necessarily encode. Embedded languages and unusual attribute scopes still need comparison. |
| JSX components | `@tag` in JavaScript and TSX uses gold for component classes, while `@tag.builtin` remains green for intrinsic tags. | Namespaced tags can contain both captures. The grammar can split the namespace, property and punctuation differently. |
| HTML doctype | `@constant.html` uses grey because the bundled doctype has a `meta.tag` scope. | The query captures the entire declaration, so quoted identifiers and other inner scopes cannot get distinct colors from this capture alone. |
| CSS selectors and keywords | Classes use `#c8a9f7`; IDs, pseudo classes and pseudo elements use attribute purple. Wildcard and nesting selectors use tag green. Properties and `!important` use orange. | The nesting selector shares a capture with the wildcard. Its actual TextMate scope may differ. Sass control captures use the source's white override, but Sass was outside the requested parser checks. |
| CSS units and color literals | `@string.css` uses orange. The installed query captures `(unit)`, `(string_value)` and `(color_value)` as `@string`. | Units and strings agree, but `constant.other.color` resolves to grey because the later Operator, Misc rule overrides the earlier white rule. Hex colors therefore need a distinct capture. Plain CSS values such as `none` can also lack a query capture even when TextMate gives them a support scope. |
| JSON nesting | All JSON and JSONC keys use the level-zero purple `#C792EA`. Every deeper source color remains in the palette. | `@property` contains no depth information. Levels one through eight need context-specific captures or an agreed exception. The query includes quotes in the key capture, while TextMate can separate quote punctuation. |
| Escapes, regular expressions and string punctuation | Escapes and regex bodies use `#89DDFF`. Regex delimiters follow punctuation, and generic special characters use orange. | Regex flags, HTML entities, template substitutions, quote marks, Python string prefixes and escape subgroups can cross different boundaries in the two tokenizers. A single string capture cannot recolor just its quotes. |
| Generic links | `Underlined` and generic `@markup.link.url` use the workbench link purple. Generic `@string.special.url` uses the red string-link rule with underline. | The source's `*url*`, `*link*` and `*uri*` selectors need checking against TextMate selector parsing. I have not treated their apparent wildcard spelling as proof of a token match. |

Markdown needs separate attention because the installed queries combine many
of the source theme's distinct scopes.

| Decision | Choice and reason | What remains uncertain |
| --- | --- | --- |
| Plain Markdown | `SpookyMarkdownText` and markup groups use `#EEFFFF`. `Normal` keeps the required global editor foreground. | The query only assigns `@spell` to ordinary inline text. Coloring that capture would also recolor comments and overlapping headings. Uncaptured Markdown prose consequently remains `#a361ff`; it needs a dedicated text capture or an agreed buffer-specific strategy. |
| Headings | All heading levels use green `#C3E88D` without added bold. | The source includes a combined heading selector containing `|`. VS Code's interpretation of that selector and the overlapping `entity.name` rule must be checked with tokenizer output. Table header cells also use a heading capture even though the source's table rule is pale white. |
| Emphasis | Italic uses italic red, and bold uses bold `#fab56b`. The named bold-italic legacy group is bold only, as the source explicitly sets `fontStyle` to `bold`. | Nested Treesitter captures combine styles and colors. They do not directly implement the theme's descendant rules for bold within italic or blockquotes. |
| Underline and strikethrough | Underline uses underlined `#F78C6C`. Strikethrough remains pale white without an added strike. | The theme has no strikethrough style rule. Any grammar-specific style inheritance needs verification. |
| Blockquotes | Quote contents use italic pale white. Distinct rendered quote markers use italic `#65737E`. | The installed block query combines quote markers, continuation markers, table punctuation and thematic breaks as `@punctuation.special`. The port gives that capture the separator rule's bold `#65737E`, so quote and table punctuation will need finer captures. |
| Fenced blocks | `@markup.raw.block.markdown` uses pale white because the later fenced-block rule overrides the earlier alpha-black rule. | That one capture also covers fence delimiters and indented blocks. Fence punctuation should retain blended `#18191e`, and ordinary raw blocks should use purple. The named fence group and render-markdown border use the distinct fence color. Injected code can override the enclosing block. |
| Fenced language labels | Labels use `#65737E` with inherited language-variable italics. | The inspected bundled Markdown grammar uses `fenced_code.block.language` rather than the theme's older `variable.language.fenced.markdown`. Tokenizer output must establish which rule is active for the installed grammar. |
| Inline code | Inline code uses purple `#C792EA`; the separate legacy punctuation group uses `#65737E`. | The Treesitter query captures the whole span and gives the same conceal capture to code and emphasis delimiters. It cannot separate those punctuation roles by color alone. |
| Link titles, descriptions and references | The shared link-label capture uses the title's `#82AAFF`. Separate named groups retain the description's purple and reference anchor's white. Markdown URL captures use the explicit `markup.underline` rule's underlined `#F78C6C`. | The installed label capture includes titles, link text, image descriptions and reference labels. Those source scopes require different colors. Link punctuation also has separate TextMate scopes. |
| Lists, tables and metadata | Lists use pale white, table text retains a named pale-white group, and metadata keeps the generic directive mapping. | The current grammar's list and quote punctuation names differ from several selectors in the theme. Markdown table headers and delimiter rows share captures with other constructs. Frontmatter can be scoped as comments or injected code. |

These workbench choices fill gaps where the JSON has no matching UI setting.
They use existing palette colors and do not claim to reproduce VS Code's
inherited workbench defaults.

| Area | Choice and reason |
| --- | --- |
| Selection and cursor | Visual selection uses both the specified purple foreground and blended background. Cursor groups use green for both foreground and background because both cursor keys are green in the JSON. Inactive terminal cursors use the status foreground against the editor background. |
| Editor guides and folds | Inactive line numbers use status grey. Nontext characters and indent guides use the subdued Markdown punctuation color. Folded text uses comment green on the sidebar surface. Cursor lines and color columns keep the editor background because no dedicated color is provided. |
| Search and references | Search uses the specified grey background with the editor foreground. Active and incremental searches share it. Matching brackets, quickfix rows, snippets and LSP references reuse the selection. |
| Floating windows and menus | Floating content and menus use the workbench green foreground and menu background. Borders use focus purple, titles use the sidebar title color, and selected menu text stays green on the specified menu selection background. There is no dedicated menu selection foreground. |
| Diagnostics and messages | Errors use the literal white `editorError.foreground`, even though invalid syntax is orange. Warning, information, hint and success use orange, blue, purple and green. Underlines and spelling indicators use those colors without introducing blended backgrounds. Unnecessary text and inlay hints use comment green. Deprecated text has a strike to preserve the diagnostic meaning. |
| Status bars and lualine | Every section c and every inactive section uses `#808080` on `#1b1d20`. Section b borrows active-tab colors. Mode indicators use existing purple, green and orange accents because the source has no modal status-bar variants. |
| Tabs and bufferline | Active and visible tabs use the active background, inactive tabs use the inactive background, and bufferline fill uses the tab-header background. Unspecified inactive text uses status grey. Diagnostic badges reuse diagnostics, and modified indicators use the markup change color. |
| Diff and Git indicators | Core diffs, gitsigns and unspecified tree Git states use generic inserted green, changed purple and deleted red. These are the spec's requested markup mappings. The older `.git_gutter` selectors have different, more specific colors, so actual gutter comparisons must decide whether those are relevant. Staged signs retain the same colors instead of applying the plugin's generated dimming. |
| Nvim-tree | The sidebar surface and global green foreground color file names. Root titles use the sidebar header purple. Icons and tree guides use icon purple. File kinds without a source setting borrow active-link orange or link purple. Merge conflicts use the exact orange conflict decoration. Both current icon groups and the older group names are supplied. |
| Telescope | All three panes use the sidebar surface, focus borders and sidebar titles. Selection uses the menu selection. Matches use active-link orange, and multiple selections use the pre-blended editor drop surface. Result kinds use their syntax groups. |
| Completion | Completion text uses menu green, matches use active-link orange, and menus use the menu background. Class, variable and field icons use their explicit purple symbol-icon settings. Other kinds use the nearest syntax group. Deprecated entries retain a strike. |
| Indent guides and which-key | Active indent scopes use focus purple. Which-key uses the menu surface, focus borders, sidebar titles and workbench foregrounds. Its named icon hues use the nearest existing palette colors. Both older and current public highlight names are defined. |
| Render-markdown | Heading colors stay uniform. Heading and code backgrounds stay at the editor background because the source has no matching background setting. Code borders, quotes, links and tables use their corresponding Markdown roles. Checkboxes retain pale text; callouts reuse diagnostics. |
| Todo-comments | The source does not distinguish TODO categories within comments. Core TODO captures therefore stay comment-colored. Plugin badges use diagnostic colors plus existing purple and green token accents; badge backgrounds invert those colors against the editor background. This plugin-specific distinction is an explicit UI approximation. |
| Unused workbench keys | Buttons, activity-bar badges, shadows and other surfaces without a requested Neovim equivalent remain represented in the palette. I did not assign those colors to unrelated editor elements merely to consume every palette entry. |

The loader clears every existing `@lsp.*` group after applying the highlight
modules, including language-specific and modifier groups, and defines empty
semantic parent groups. It does not disable LSP features. A plugin that
explicitly assigns semantic highlight colors after the colorscheme loads can
still replace those empty definitions; no global callback intercepts such
later user or plugin changes.

Legacy syntax uses the same role colors, with additional HTML, CSS, JSON,
Markdown and diff aliases. Builtin legacy syntax can group tokens differently
from both TextMate and Treesitter. In particular, plain Markdown, code-fence
boundaries, string quotes and language-specific types need separate legacy
coverage if the comparison harness is extended beyond Treesitter.

Validation completed on Neovim 0.11.6:

- The required command exited zero and produced no output:
  `nvim --headless --clean --cmd "set rtp+=$PWD" -c "colorscheme spooky-scary" -c q`.
- A palette audit verified all 40 distinct source hex literals are represented,
  every unblended six-digit palette color occurs in the source, and all five
  blends equal the independently calculated rounded values.
- An isolated Lua check resolved all 746 highlight definitions, checked that
  links have targets, loaded the scheme twice with identical resulting groups,
  and verified seeded LSP type and modifier overrides were cleared.
- The same check loaded all seven lualine mode tables and exercised installed
  queries and parsers for JavaScript, TypeScript, TSX, HTML, CSS, JSON, Markdown,
  Markdown inline, Python and Lua. Every visible capture had a foreground.
  Private query captures and spelling/conceal controls were excluded from that
  foreground assertion.
- The complete added-file diff was inspected. The comparison harness and manual
  VS Code screenshot comparison remain pending.

Git staging was attempted on the existing `nvim-fork-codex` branch. The sandbox
refused to create
`/Users/benjaminchavez/Code/spooky-scary-color-theme/.git/worktrees/spooky-scary-color-theme-codex/index.lock`.
That Git metadata directory is outside the writable workspace. No commit could
be created in this session. The pre-existing `.nvimlog` and untracked Codex brief
were excluded from the staging command.
