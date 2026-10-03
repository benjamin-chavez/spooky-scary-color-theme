Round 1 reconciliation of the Spooky Scary Neovim ports

Date: 2026-10-02. This report concerns `nvim-fork-codex` and the sibling `nvim-fork` checkout. No commit or index write was attempted.

All 68 aggregate rows in the supplied Codex diff are fixed in the rendered output. Those rows contained 479 unexplained runs. The remaining rendered differences total 73 of 6,985 characters in 13 runs. They concern JSON key depth, unavailable LuaDoc parsing, Python builtin type calls, and Python raw-string regular expressions. I do not consider those results sufficient for one-to-one agreement.

I read the sibling harness scripts, the complete design document and query amendment, all eight query extensions, all four group modules, the palette, and all 51 provisional exceptions. I also inspected the installed base queries and Neovim 0.11.6 highlighting implementation. The sibling harness and exception file were left unchanged.

The evidence below comes from the actual inspectors, including the requested `sample.js 12` invocation. I ran the TextMate inspector for all 289 nonempty sample lines and the capture inspector for the disputed constructs. Scope excerpts preserve the relevant emitted ancestors and leaf scopes. Markdown’s root `text.html.markdown` is omitted by the inspector itself. Font styles come from `tokenizeLine2` output and the theme settings, since `--scopes` prints foregrounds but does not print style flags.

```sh
cd ../spooky-scary-color-theme
node tools/compare/vscode-tokens.mjs --scopes sample.js 12
nvim --headless --clean -l tools/compare/nvim-captures.lua sample.js 12
```

The cited theme rules are linked to the source JSON at the end of this report. Sample names and line numbers refer to the sibling [comparison samples](../../../../spooky-scary-color-theme/tools/compare/samples).

**1. Shipping query extensions is acceptable for this port, provided their behavior is explicit.** Neovim supports `;; extends` on the runtime path. Queries can distinguish syntax that the stock captures combine. A colorscheme claiming to reproduce TextMate needs that extra information. A missing stock capture is not an inherent parser limitation.

The amendment’s claim that its capture names leave other schemes unchanged is false. Falling back to a standard capture does not restore the capture that originally won on that node. I compared Neovim’s default colorscheme with no theme queries, with the sibling queries, and with this port’s private queries. The sibling queries changed 446 visible characters across the samples. The private queries changed zero. For example, the default scheme’s CSS quote foreground changed from `#b3f6c0` to `#e0e2ea` with the sibling extension.

| Sibling capture | Fallback or override consequence |
| --- | --- |
| `@punctuation.delimiter.string` | It falls back to punctuation over a token previously colored as a string. This changes quotes in CSS, HTML, JavaScript, Lua, and Python. Python prefixes are also swept into this capture. |
| `@variable.block` | It can replace `@constant`, `@type`, `@variable.builtin`, `@variable.member`, or `@function` with the generic variable foreground. Its function-name exclusions do not cover variables initialized with arrow functions. |
| `@variable.capitalized` | It replaces the base type and builtin-type heuristics with `@variable`. That is intentional for this theme, but changes another scheme’s result. |
| `@variable.member.key` | It can replace `@function.method` on an object key whose value is a function. Its fallback does not preserve the original method classification. |
| `@variable.argument` | It falls back to `@variable` even over Python builtin types, language variables, and lambda parameters. The blanket ancestor rule changes more than otherwise unscoped arguments. |
| `@punctuation.delimiter.annotation` | Python’s arrow was `@operator`; its fallback becomes punctuation. |
| `@punctuation.delimiter.type` | TypeScript union and intersection operators can fall back to punctuation instead of `@operator`. |
| `@keyword.import.type` | It changes the `type` token’s fallback from its base type-keyword classification to an import classification. |
| The added standard `@keyword.operator` capture | It changes loop `of` from the base repeat capture to an operator capture. Using a standard capture name does not make that change neutral. |
| `@markup.plain` | Its fallback is `@markup`. The claim that no scheme defines that group is not a contract; the original Codex port already defined it. An otherwise uncaptured region can acquire a foreground. |

The round/square/parameter bracket subcaptures, parameter/label delimiter subcaptures, and CSS `@string.color` generally fall back to the base category already present. The inherited-type, constructor, await, and default subcaptures also often retain their original base category. That narrower observation does not justify a blanket promise about every scheme, especially one defining more specific groups.

This port therefore uses only `@spooky.*` highlight captures in its extensions. Other schemes have no standard fallback for that prefix. The theme supplies their highlights while active; normal colorscheme clearing removes them when switching. This preserves the existing base captures for other schemes. Parser and query evaluation still have a small runtime cost, and parser-version compatibility still needs maintenance.

CSS `(plain_value)` should get a capture. With an ordinary `@constant` capture I would accept the documented fallback cost only as an explicit opt-in. With a private capture there is no need for that cost. The implementation colors plain values orange and leaves `--custom-property` references with their existing variable treatment. `sample.css:15` reports `support.constant.font-name.css` for `sans-serif`; lines 22, 29, and 31 report `support.constant.property-value.css`. The constant rule supplies orange in both cases.

The rules I reject include treating every class body as `meta.block`, treating every descendant of a Python argument list as a plain argument, treating all Python `string_start` bytes as punctuation, and treating all Markdown link labels as the same scope. The specific corrections and counterexamples appear below.

**2. Every supplied aggregate row has a concrete correction.** The following table accounts for all 68 rows by sample, original run count, and original VS Code/Neovim color pair. Every row is fixed in the screen-based comparison, including its styles. I am not classifying any of these original unexplained rows as inherent.

The last column counts how many original runs the other port already matched completely. A partial count distinguishes a useful foreground correction from a remaining style or context error.

| Row | Sample and runs | VS Code / old Codex | Inspector evidence and correction | Other port already correct |
| --- | --- | --- | --- | --- |
| 1 | `sample.css`, 10 | `#afafaf` / `#fca03f` | `sample.css:2,6`: `punctuation.definition.string.begin.css` and `constant.other.color.rgb-value.hex.css` both use [Operator, Misc]. I added separate quote and color captures. | 10/10 |
| 2 | `sample.css`, 1 | `#a361ff` / `#fca03f` | `sample.css:3`: the entire quoted value has only `meta.at-rule.header.css`. No token rule matches. I restored the editor foreground for the complete charset value. | 0/1 |
| 3 | `sample.html`, 31 | `#afafaf` / `#fca03f` | `sample.html:2`: `string.quoted.double.html punctuation.definition.string.begin.html` uses [Operator, Misc]. I separated attribute quotes from their contents. | 31/31 |
| 4 | `sample.html`, 5 | `#a361ff` / `#afafaf` | `sample.html:23,24`: `meta.brace.round.js` has no matching rule. Empty bracket highlights now inherit the editor foreground outside Markdown and JSX. | 5/5 |
| 5 | `sample.html`, 1 | `#90f078` / `#afafaf` | `sample.html:1`: `entity.name.tag.html` uses [Tag]. The doctype keyword is green. | 1/1 |
| 6 | `sample.html`, 1 | `#fca03f italic` / `#afafaf` | `sample.html:1`: `entity.other.attribute-name.html` beneath `text.html.basic` uses [HTML Attributes]. A guarded range gives HTML5 doctype attributes orange italics. | 0/1 |
| 7 | `sample.js`, 32 | `#d8d8d8` / `#90f078` | `sample.js:3,15,16`: `meta.block.js variable.other.readwrite.alias.js` and `meta.block.js variable.other.readwrite.js` use [Block Level Variables]. Context captures now supply the white foreground. | 32/32 |
| 8 | `sample.js`, 25 | `#a361ff` / `#afafaf` | `sample.js:15,25`: `meta.brace.round.js` has no matching rule. Calls inherit the editor foreground; parameter punctuation remains grey. | 25/25 |
| 9 | `sample.js`, 21 | `#afafaf` / `#fca03f` | `sample.js:3,21`: `punctuation.definition.string.begin.js` and `punctuation.definition.string.template.begin.js` use [Operator, Misc]. Quote captures now override string orange. | 21/21 |
| 10 | `sample.js`, 3 | `#a361ff` / `#90f078` | `sample.js:43,54`: `support.variable.property.js` on `length` and `meta.object-literal.key.js` on object keys match no rule. I separated the lexical `length` case and object keys from ordinary members. | 2/3 |
| 11 | `sample.js`, 2 | `#894fe0` / `#afafaf` | `sample.js:24,26`: `storage.modifier.async.js` and `keyword.operator.expression.of.js` use [Keyword, Storage]. Await remains grey through its separate control scope. | 2/2 |
| 12 | `sample.js`, 1 | `#894fe0` / `#ffcb6b` | `sample.js:14`: `storage.type.js` uses [Keyword, Storage]. The constructor keyword no longer takes the class color. | 1/1 |
| 13 | `sample.js`, 1 | `#90f078` / `#fca03f` | `sample.js:6`: `variable.other.constant.js` uses [Variables]. Uppercase spelling does not make this a TextMate constant. | 1/1 |
| 14 | `sample.js`, 1 | `#afafaf` / `#894fe0` | `sample.js:56`: `keyword.control.default.js` uses [Operator, Misc]. The export default keyword is grey. | 1/1 |
| 15 | `sample.js`, 1 | `#d8d8d8` / `#894fe0 italic` | `sample.js:48`: `meta.block.js variable.other.object.js` uses [Block Level Variables], without a language-variable style. I removed the builtin-name italic heuristic for this identifier. | 0/1 |
| 16 | `sample.js`, 1 | `#d8d8d8` / `#fca03f` | `sample.js:27`: `meta.block.js variable.other.constant.js` uses [Block Level Variables]. The reference is white inside the block. | 1/1 |
| 17 | `sample.js`, 1 | `#fca03f` / `#ffcb6b` | `sample.js:10`: `entity.other.inherited-class.js` uses [String, Symbols, Inherited Class, Markup Heading]. The superclass is orange. | 1/1 |
| 18 | `sample.json`, 28 | `#afafaf` / `#c792ea` | `sample.json:2`: `support.type.property-name.json punctuation.support.type.property-name.begin.json` uses [Operator, Misc]. Only actual quote tokens receive the punctuation capture. | 28/28 |
| 19 | `sample.json`, 12 | `#afafaf` / `#fca03f` | `sample.json:2`: `punctuation.definition.string.begin.json` uses [Operator, Misc]. Value quotes are grey without recoloring escapes. | 12/12 |
| 20 | `sample.lua`, 32 | `#a361ff` / `#afafaf` | `sample.lua:4,10,11`: table braces, ordinary access dots, and call punctuation have no matching TextMate rule. I restored the editor foreground and kept separately scoped parameter punctuation grey. | 32/32 |
| 21 | `sample.lua`, 12 | `#afafaf` / `#fca03f` | `sample.lua:12,22`: `punctuation.definition.string.begin.lua` uses [Operator, Misc]. String contents retain orange. | 12/12 |
| 22 | `sample.lua`, 2 | `#fca03f` / `#ffcb6b` | `sample.lua:32,34`: `string.tag.lua` uses [String, Symbols, Inherited Class, Markup Heading]. Label names are orange, with grey `punctuation.section.embedded` delimiters. | 2/2 |
| 23 | `sample.lua`, 1 | `#b184dd` / `#afafaf` | `sample.lua:18`: the complete `string.format` token has `support.function.library.lua`. [Function, Special Method] also colors its dot. A library-access capture fixes the dot. | 0/1 |
| 24 | `sample.md`, 32 | `#eeffff` / `#a361ff` | `sample.md:5`: `meta.paragraph.markdown` inherits [Markdown - Plain] from `text.html.markdown`. A low-priority prose capture supplies pale white. | 32/32 |
| 25 | `sample.md`, 12 | `#afafaf` / `#eeffff` | `sample.md:5,9,25,28`: `punctuation.definition.strikethrough.markdown`, `punctuation.definition.list.begin.markdown`, and `punctuation.definition.markdown` use [Operator, Misc]. I separated list and fence punctuation from prose. | 10/12 |
| 26 | `sample.md`, 11 | `#afafaf` / `#65737e bold` | `sample.md:32,33,34`: `punctuation.definition.table.markdown` uses [Operator, Misc]. Table punctuation no longer borrows separator bold styling. | 11/11 |
| 27 | `sample.md`, 4 | `#afafaf bold` / `#fab56b bold italic` | `sample.md:5,7`: punctuation nested under `markup.bold.markdown` uses [Operator, Misc] with [Markup - Bold] or [Markup - Bold-Italic]. Explicit bold delimiters reset inherited italics. | 0/4 |
| 28 | `sample.md`, 4 | `#ffcb6b` / `#c3e88d` | `sample.md:1,3`: `markup.heading.markdown entity.name.section.markdown` resolves through [Class, Support]. Heading text is gold; markers remain separately green. | 4/4 |
| 29 | `sample.md`, 3 | `#c792ea` / `#eeffff` | `sample.md:30`: `markup.raw.block.markdown` uses [Markup - Raw Block]. Only indented blocks receive purple. | 3/3 |
| 30 | `sample.md`, 2 | `#afafaf` / `#82aaff` | `sample.md:21`: `punctuation.definition.constant.markdown` uses [Operator, Misc]. Reference-definition brackets have their own capture. | 0/2 |
| 31 | `sample.md`, 2 | `#afafaf` / `#c792ea` | `sample.md:5`: `markup.inline.raw.string.markdown punctuation.definition.raw.markdown` uses [Operator, Misc]. The old raw-inline punctuation selector does not match this stack. | 2/2 |
| 32 | `sample.md`, 2 | `#afafaf` / `#fca03f` | `sample.md:26`: injected JavaScript quotes carry `punctuation.definition.string.begin.js` and use [Operator, Misc]. The shared JavaScript quote rule fixes them. | 2/2 |
| 33 | `sample.md`, 2 | `#afafaf bold` / `#f07178 italic` | `sample.md:5`: the inner `punctuation.definition.italic.markdown` is under both `markup.bold.markdown` and `markup.italic.markdown`. [Markup - Bold-Italic] specifies bold only. Delimiter captures enforce that style. | 0/2 |
| 34 | `sample.md`, 2 | `#afafaf bold` / `#fab56b bold` | `sample.md:5`: `markup.bold.markdown punctuation.definition.bold.markdown` combines [Operator, Misc] with [Markup - Bold]. The delimiters are grey and bold. | 2/2 |
| 35 | `sample.md`, 2 | `#afafaf italic` / `#f07178 italic` | `sample.md:5`: `markup.italic.markdown punctuation.definition.italic.markdown` combines [Operator, Misc] with [Markup - Italic]. The delimiters are grey and italic. | 2/2 |
| 36 | `sample.md`, 2 | `#eeffff` / `#afafaf` | `sample.md:27`: injected `meta.brace.round.js` has no foreground rule and inherits [Markdown - Plain]. Neutral JavaScript brackets now preserve the surrounding fenced-block foreground. | 0/2 |
| 37 | `sample.md`, 2 | `#eeffff` / `#c3e88d` | `sample.md:32`: `markup.table.markdown` uses [Markup - Table]. The table-heading capture now stays pale white. | 2/2 |
| 38 | `sample.md`, 2 | `#eeffff` / `#c792ea` | `sample.md:5`: `markup.inline.raw.string.markdown` does not match the theme’s `markup.inline.raw.markdown` selector. It inherits [Markdown - Plain]. Inline code is pale white. | 2/2 |
| 39 | `sample.md`, 1 | `#82aaff` / `#eeffff` | `sample.md:15`: `string.other.link.title.markdown` uses [Markdown - Link]. A range capture colors only the checked marker’s letter blue. | 0/1 |
| 40 | `sample.md`, 1 | `#afafaf italic` / `#65737e bold italic` | `sample.md:7`: `markup.quote.markdown punctuation.definition.quote.begin.markdown` combines [Operator, Misc] with [Markup - Quote]. The marker is grey and italic, without bold. | 1/1 |
| 41 | `sample.md`, 1 | `#eeffff` / `#65737e italic` | `sample.md:25`: `markup.fenced_code.block.markdown fenced_code.block.language.markdown` inherits [Markdown - Plain]. The obsolete `variable.language.fenced.markdown` selector does not match. | 1/1 |
| 42 | `sample.md`, 1 | `#ffffff` / `#82aaff` | `sample.md:21`: `constant.other.reference.link.markdown` uses [Markdown - Link Anchor]. The reference name is white. | 1/1 |
| 43 | `sample.py`, 26 | `#afafaf` / `#fca03f` | `sample.py:1,11,26`: `punctuation.definition.string.begin.python` and the matching end scope use [Operator, Misc]. String boundaries now have separate captures, with an f-string exception. | 26/26 |
| 44 | `sample.py`, 8 | `#b184dd` / `#a361ff` | `sample.py:16,29,32,43,45`: otherwise uncolored names inside `meta.function-call.python` inherit [Function, Special Method]. Low-priority argument captures preserve more specific parameters and builtin types. | 8/8 |
| 45 | `sample.py`, 6 | `#afafaf` / `#894fe0` | `sample.py:15,21,25,33,36,40`: `punctuation.separator.annotation.result.python` and `keyword.control.flow.python` use [Operator, Misc]. Return arrows, `as`, and `pass` are grey. | 6/6 |
| 46 | `sample.py`, 4 | `#a361ff` / `#ffcb6b` | `sample.py:4,40`: imported names have no scope; annotations have no matching foreground selector for these names. I removed the capitalization-based type foreground while keeping class definitions gold. | 4/4 |
| 47 | `sample.py`, 4 | `#fca03f` / `#afafaf` | `sample.py:22`: `constant.character.format.placeholder.other.python` uses [Number, Constant, Function Argument, Tag Attribute, Embedded]. Interpolation braces are orange. | 4/4 |
| 48 | `sample.py`, 3 | `#894fe0` / `#fca03f` | `sample.py:22,26`: `storage.type.string.python` uses [Keyword, Storage]. Offset captures separate the prefix from the quote in `string_start`. | 0/3 |
| 49 | `sample.py`, 2 | `#afafaf` / `#b184dd` | `sample.py:20,24`: `punctuation.definition.decorator.python` uses [Operator, Misc]. A capture above the base query’s priority 101 colors only `@` grey. | 0/2 |
| 50 | `sample.py`, 2 | `#f17008` / `#b184dd` | `sample.py:20,24`: `support.type.python` uses the later [Entity Types] rule. Builtin decorator names are burnt orange; ordinary decorators retain the function color. | 2/2 |
| 51 | `sample.py`, 1 | `#fca03f` / `#ffcb6b` | `sample.py:10`: `entity.other.inherited-class.python` uses [String, Symbols, Inherited Class, Markup Heading]. The superclass is orange. | 1/1 |
| 52 | `sample.ts`, 19 | `#894fe0` / `#afafaf` | `sample.ts:5,6,7`: `keyword.operator.type.annotation.ts`, `keyword.operator.type.ts`, and `keyword.operator.optional.ts` use [Keyword, Storage]. Type punctuation is purple. | 19/19 |
| 53 | `sample.ts`, 18 | `#afafaf` / `#fca03f` | `sample.ts:2,6`: `punctuation.definition.string.begin.ts` uses [Operator, Misc]. Quotes are grey. | 18/18 |
| 54 | `sample.ts`, 17 | `#d8d8d8` / `#90f078` | `sample.ts:23,29,33`: `meta.block.ts variable.other.property.ts` and ordinary block references use [Block Level Variables]. Only actual block contexts receive white. | 17/17 |
| 55 | `sample.ts`, 14 | `#a361ff` / `#afafaf` | `sample.ts:19,28`: `meta.brace.square.ts` and `meta.brace.round.ts` have no matching foreground rule. Type-parameter angle brackets retain their separate grey punctuation. | 14/14 |
| 56 | `sample.ts`, 3 | `#a361ff` / `#90f078` | `sample.ts:49`: `meta.object-literal.key.ts` has no matching rule. Literal keys inherit the editor foreground. | 3/3 |
| 57 | `sample.ts`, 2 | `#d8d8d8` / `#ffcb6b` | `sample.ts:2,23`: `meta.block.ts variable.other.readwrite.alias.ts` and `meta.block.ts variable.other.object.ts` use [Block Level Variables]. Capitalization no longer overrides block context. | 2/2 |
| 58 | `sample.ts`, 1 | `#894fe0` / `#ffcb6b` | `sample.ts:22`: `storage.type.ts` uses [Keyword, Storage]. Constructor keywords are purple. | 1/1 |
| 59 | `sample.ts`, 1 | `#90f078` / `#f17008` | `sample.ts:28`: `variable.other.object.ts` uses [Variables]. The computed method name is outside `meta.block`; removing the class-body approximation preserves green. | 0/1 |
| 60 | `sample.ts`, 1 | `#90f078` / `#ffcb6b` | `sample.ts:48`: the value-position `Phase` is `variable.other.object.ts` and uses [Variables]. Its type-position occurrence remains gold through `entity.name.type.ts`. | 1/1 |
| 61 | `sample.ts`, 1 | `#afafaf` / `#894fe0` | `sample.ts:2`: `keyword.control.type.ts` uses [Operator, Misc]. The `import type` modifier is grey. | 1/1 |
| 62 | `sample.ts`, 1 | `#fca03f` / `#ffcb6b` | `sample.ts:18`: `entity.other.inherited-class.ts` uses [String, Symbols, Inherited Class, Markup Heading]. Implemented types are orange. | 1/1 |
| 63 | `sample.tsx`, 11 | `#d8d8d8` / `#90f078` | `sample.tsx:1,6,7,10,11`: aliases and references beneath `meta.block.tsx` use [Block Level Variables]. The TypeScript extension restores these captures after its base query. | 11/11 |
| 64 | `sample.tsx`, 10 | `#afafaf` / `#fca03f` | `sample.tsx:1,7,10`: `punctuation.definition.string.begin.tsx` uses [Operator, Misc]. Both script and JSX attribute quotes are grey. | 10/10 |
| 65 | `sample.tsx`, 4 | `#a361ff` / `#afafaf` | `sample.tsx:6,9`: `meta.brace.round.tsx` has no matching rule outside JSX tags. Neutral captures preserve the editor foreground. | 4/4 |
| 66 | `sample.tsx`, 3 | `#894fe0` / `#afafaf` | `sample.tsx:3,5`: `keyword.operator.type.annotation.tsx` and `keyword.operator.optional.tsx` use [Keyword, Storage]. Type punctuation is purple. | 3/3 |
| 67 | `sample.tsx`, 3 | `#afafaf` / `#a361ff` | `sample.tsx:13,16`: text under `meta.tag.tsx meta.jsx.children.tsx` inherits [Operator, Misc]. JSX text now receives grey. | 3/3 |
| 68 | `sample.tsx`, 1 | `#90f078` / `#ffcb6b` | `sample.tsx:1`: `variable.other.readwrite.alias.tsx` uses [Variables]. The default import is green, while the named import inside braces uses block white. | 1/1 |

**3. The full module review supports many of the other port’s corrections, but not its remaining exceptions.** I reviewed `editor.lua`, `syntax.lua`, `treesitter.lua`, `plugins.lua`, `palette.lua`, and every sibling highlight extension in full. I also read its loader and lualine module. The palette literals and alpha blending agree with the source; its palette check exits zero. In the clean installed Neovim, its loader leaves no nonempty LSP highlight definitions. I found no additional source-backed defect in those two areas.

These are the mappings where the other port was right and the original Codex port was wrong. The table above gives the exact scope, rule, count, and example for each affected aggregate.

| Other-port mapping that was correct | Evidence from the aggregate table |
| --- | --- |
| String quotes map to punctuation, and CSS `constant.other.color` maps to grey. | Rows 1, 3, 9, 18, 19, 21, 32, 43, 53, and 64 show the [Operator, Misc] rule winning over broader strings or the earlier Colors rule. |
| Ordinary call and array brackets differ from parameter and destructuring punctuation. | Rows 4, 8, 20, 55, and 65 show uncolored `meta.brace` or unscoped Lua punctuation. The Markdown and JSX inheritance exceptions still need the narrower treatment described below. |
| Actual block variables, including named imports and capitalized value references, are white. | Rows 7, 16, 54, 57, and 63 use [Block Level Variables]. The sibling’s inclusion of all class bodies was too broad. |
| JavaScript uppercase declarations stay green; constructors and `async`/`of` use keyword purple; `export default` uses grey. | Rows 11–14 show [Variables], [Keyword, Storage], and [Operator, Misc] applying to distinct scopes. |
| Inherited and implemented class names are orange. | Rows 17, 51, and 62 use [String, Symbols, Inherited Class, Markup Heading]. |
| Object-literal keys have no matching foreground selector. | The `house` and `ghosts` portions of row 10 and all of row 56 should inherit the editor foreground. The sibling did not correctly handle the separate `length` case in row 10. |
| `DOCTYPE` itself is a green tag name. | Row 5 uses [Tag]. This does not justify coloring the following `html` attribute green. |
| Lua labels are orange and ordinary Lua punctuation is uncolored. | Rows 20 and 22 use the unscoped foreground and the `string.tag.lua` scope respectively. |
| Markdown prose, inline-code contents, fenced language labels, and table cells are pale white. | Rows 24, 37, 38, and 41 follow the actual grammar’s [Markdown - Plain] and [Markup - Table] scopes. |
| Markdown heading text is gold and indented code is purple. | Rows 28 and 29 use [Class, Support] and [Markup - Raw Block]. These differ from heading markers and fenced-block contents. |
| Ordinary emphasis, code, list, table, and quote punctuation is grey. | Rows 25, 26, 31, 34, 35, and 40 support this foreground correction. The sibling still gets nested bold styles and fence delimiters wrong. |
| Reference-definition names are white. | Row 42 uses [Markdown - Link Anchor]. Its surrounding brackets need their own punctuation capture. |
| Plain Python imported/annotated names stay at the editor foreground; class definitions retain gold. | Row 46 follows the actual absence of a matching type rule. The explicit class-definition scope still uses [Class, Support]. |
| Plain Python call arguments inherit the function color; return arrows and control words are grey. | Rows 44 and 45 use [Function, Special Method] and [Operator, Misc]. This does not authorize overriding more specific parameter, builtin-type, or language-variable scopes. |
| Python interpolation braces are orange and builtin decorator names use burnt orange. | Rows 47 and 50 use the constant rule and [Entity Types]. The decorator `@` is separate punctuation. |
| TypeScript type punctuation is purple, `import type` is grey, and value-position capitals remain variables. | Rows 52, 58, 60, 61, 66, and 68 support these distinctions. |
| JSX text inherits grey from `meta.tag`. | Row 67 uses [Operator, Misc]. Plain HTML presentation-tag contents remain at their ordinary editor foreground. |
| Python `async` uses keyword purple. | The additional `async def work():` probe emits `storage.type.function.async.python` and `#894fe0`. The sibling’s generic coroutine color was correct for `async`; I added that correction. Its mapping is wrong for `await`, described below. |

The following mappings in the other port are wrong or insufficient for the source scopes. The exception review in part 4 supplies the individual evidence and proposed fix for every corpus occurrence.

| Other-port definition or query | Finding |
| --- | --- |
| CSS `@string`, `@number`, `@variable`, and uncaptured plain values | Charset values and keyframe offsets need the editor foreground; plain values and keyframe names need orange. Entries 1–4 are fixable context differences. |
| HTML `@constant.html` and `@character.special.html` | Whole-doctype green loses the orange italic attribute. Whole-entity orange loses grey punctuation. Entries 5–6 can be split with ranges. |
| ECMAScript `@variable.builtin` | `document` and `console` are ordinary variables here, while `this`, `super`, and `arguments` have language-variable scopes. Entries 7, 10, and 11 incorrectly accept this mixture. |
| Generic `@character.special` linked to `SpecialChar` | JavaScript regex flags already have `@character.special.javascript`; they are not part of the regex-body capture. Entry 8 needs the orange keyword-other mapping. |
| `@variable.block` queries with a `class_body` ancestor | A class body is not automatically `meta.block`. Entry 49 and the class-field probe below demonstrate false white variables. |
| `@variable.block` and capitalization queries without function-valued binding restoration | A binding such as `const inner = () => {}` inside a function has `entity.name.function.js` and must remain function purple. The sibling’s final block capture makes it white. I restored function-valued bindings after the block rule. |
| `@variable.member` and `@variable.block` on known property names | The `length` token has `support.variable.property.js`, not a variable scope. Entry 9 should use the grammar’s lexical property list rather than a semantic DOM argument. |
| `@property.json` for every nesting depth | The theme has distinct key-depth rules. Entries 12–14 are missing context computation, not information missing from the tree. |
| `@conceal.json` colored grey | That control capture also occurs on escaped quotes. Entry 15 should color actual quote tokens only. Entry 16 separately needs the full Unicode-escape range. |
| Lua `@variable.member`, ordinary variable captures on method/function prefixes, and plain punctuation on library dots | Entries 17–20 lose the distinct attribute, class-name, function-name, and library-function scopes. |
| Lua generic `@keyword` for `in` and `goto` | Entry 21 needs grey control keywords. Purple `local` does not justify a shared color for these tokens. |
| Markdown `@markup.strong`, `@markup.italic`, and delimiter captures | Entries 25–27 need explicit style resets and correct delimiter captures. The theme’s combined-emphasis rule is bold only. |
| Markdown heading, raw-block, punctuation, and list captures | Entries 28, 32, 36, 37, and 39 need separate markers, unchecked/checked tasks, fence delimiters, and thematic breaks. A single color for each broad base category is insufficient. |
| Markdown shared link labels, references, and URL ranges | Entries 29–31, 34–35, and 38 need title, image-description, reference, punctuation, and URL-body distinctions. |
| Markdown `@markup.strikethrough` and `@markup.strikethrough.markdown_inline` | They add a strike that no `tokenColors` rule requests. `sample.md:5` emits `markup.strikethrough.markdown`, which inherits pale white with no style. The supplied harness does not compare the strike bit. Codex retains the unstruck mapping. |
| Python string-start punctuation | Entry 40 incorrectly includes prefixes; entry 45 ignores the f-string scope order. Quotes and prefixes require separate ranges. |
| Python `@variable.argument` with a blanket argument-list ancestor | It overrides `self`, builtin types, and lambda parameters, and excludes a keyword argument’s value along with its name. The probe below demonstrates all four errors. I use priority 99 for inherited argument foreground and leave otherwise unscoped Python groups without a foreground, allowing specific captures to win. |
| Python `@attribute.python` applied to every decorator | `@decorate` uses `entity.name.function.decorator.python`, so the name is function purple. Only the builtin decorator names in the sample have `support.type.python`. Entry 44 separately needs grey marker punctuation. Codex preserves ordinary decorator functions. |
| Python `@variable.builtin`, call/type ordering, and magic builtin constants | Entries 42, 43, and 48 require parameter context, builtin-type precedence, and an uncolored magic-variable case. |
| Python operator and raw-string captures | Entries 41, 46, and 47 require comprehension context and regex parsing. The compound `is not` node contains separately captured child tokens, so the correction needs higher priority. |
| TypeScript uncaptured `this_type` and bracket foregrounds | Entry 50 needs a builtin-type capture. Entry 51 is an inherited JSX foreground problem on call parentheses, not a missing arrow-parameter node. |
| Generic `@attribute` with blue italics for JavaScript decorators | `@decorate class Example {}` emits grey `punctuation.decorator.js` for `@` and green `variable.other.readwrite.js` for `decorate`. The old [Decorators] selector requires `tag.decorator.js`, which this grammar does not emit. I corrected the current grammar’s simple decorator case. |
| `@comment.todo`, `@comment.error`, `@comment.note`, `@comment.warning`, and legacy `Todo` | The comment probe emits only `comment.line.double-slash.js` and [Comment] supplies blended italic green throughout. The sibling’s comment injection adds unrelated foregrounds or a bold badge. Codex’s core comment mappings were already correct. Plugin badges remain a separate UI policy. |
| Generic `@keyword.directive`, `PreProc`, and `Define` | A JS/Lua shebang is a comment, while JS `"use strict"` is a string. Neither is a grey control keyword. The probes below give their actual scopes. Codex’s Python/Lua shebang and directive-string treatments were already correct; I added a private JS shebang capture. |
| Generic ECMAScript `@keyword` for `break` and `debugger` | `break` emits `keyword.control.loop.js` and grey; `debugger` emits `keyword.other.debugger.js` and orange. Neither should inherit generic purple. I added explicit captures. |
| Generic Python `@keyword.coroutine` for `await` | `await` emits `keyword.control.flow.python` and grey. The sibling gives it keyword purple. Codex’s existing await color was correct. |

These additional snippets were written only to temporary files, leaving the shared fixtures intact. Both supplied inspectors were run against them. The output excerpts above and below identify the precise rules being disputed.

```javascript
const factory = () => {};
function outer() { const inner = () => {}; return inner; }
class Example { field = value; [Symbol.iterator]() { return this; } }
function args() { return arguments; }
// TODO FIXME NOTE WARNING
@decorate class Example {}
```

The binding `inner` emits `meta.block.js ... variable.other.constant.js entity.name.function.js` with `#b184dd`. The sibling capture inspector reports `@variable @function @variable.block` on that binding. The class-field value emits `meta.class.js meta.field.declaration.js variable.other.readwrite.js` with `#90f078`; the sibling adds `@variable.block` despite the absence of `meta.block`. The `arguments` reference emits `meta.block.js variable.language.arguments.js` with italic `#894fe0`, but the sibling also adds its white block-variable capture.

```python
@decorate
def example(self):
    return call(self, int, obj.name, lambda x: x, value=other)
```

The call’s `self` emits `variable.language.special.self.python` with italic `#894fe0`; `int` emits `support.type.python` with `#f17008`; the first lambda `x` emits `variable.parameter.function.language.python` with `#fca03f`; `other` has only `meta.function-call.python meta.function-call.arguments.python` and resolves to `#b184dd`. The sibling inspector adds `@variable.argument` to the first three, but omits it from `other` because its direct parent is `keyword_argument`.

| Additional keyword probe | Inspector result and source rule |
| --- | --- |
| JS `#!/usr/bin/env node` | `comment.line.shebang.js` resolves to italic `#679e63` through [Comment]; the base capture is `@keyword.directive.javascript`. |
| Lua `#!/usr/bin/env lua` | `comment.line.shebang.lua` resolves to italic `#679e63` through [Comment]; the base capture is `@keyword.directive.lua`. |
| Python `#!/usr/bin/env python3` | `comment.line.number-sign.python` resolves to italic `#679e63` through [Comment]; a later `@keyword.directive.python` overlaps the comment. |
| JS `"use strict";` | The contents have `string.quoted.double.js` and `#fca03f` through [String, Symbols, Inherited Class, Markup Heading]. The base query also captures `use strict` as a directive. |
| JS `while (true) { break; }` | `break` has `keyword.control.loop.js` and `#afafaf` through [Operator, Misc]. |
| JS `debugger;` | `keyword.other.debugger.js` resolves to `#fca03f` through [Number, Constant, Function Argument, Tag Attribute, Embedded]. |
| Python `async def work():` | `async` has `storage.type.function.async.python` and `#894fe0` through [Keyword, Storage]. |
| Python `await run()` | `await` has `keyword.control.flow.python` and `#afafaf` through [Operator, Misc]. |

There are also explicit workbench deviations in the sibling editor module. `Visual` omits the specified `editor.selectionForeground` (`#894fe0`); `Cursor` uses the editor background as its foreground although `editorCursor.foreground` is `#90f078`; `CurSearch` uses green instead of the specified grey `editor.findMatchBackground`. These are literal source-key comparisons. TextMate scopes do not exist for workbench settings, so a token inspector cannot settle them. Codex keeps the literal selection, cursor, and search values. Unspecified UI colors remain approximations in both ports; I did not treat different palette choices for unspecified roles as errors.

The plugin review also exposes source-token discrepancies if the render-markdown groups are intended to replace the corresponding source text. The sibling’s `RenderMarkdownH1` through `RenderMarkdownH6` use green bold text instead of the gold heading text at `sample.md:1,3`; `RenderMarkdownCodeInline` uses purple instead of the pale inline code at line 5; `RenderMarkdownBullet` uses pale white instead of grey list punctuation at line 9; `RenderMarkdownQuote` uses muted grey instead of the grey italic marker at line 7; `RenderMarkdownChecked` uses inserted green instead of the blue `x` at line 15; and `RenderMarkdownTableHead` adds bold to the unstyled table text at line 32. The theme rules and emitted scopes for all of these are in the aggregate table. Some of these approximations are shared by Codex’s plugin module. They remain separate from this round’s source-token fixes because the comparison harness does not run that renderer. Rendered icons, backgrounds, and modal UI decorations have no direct TextMate token equivalent. I found no further source-backed objection to the other requested plugin mappings.

**4. Every provisional exception has been reviewed individually.** Entry numbers below are their one-based positions in the supplied `known-differences.json`. “Disagree” means I reject retaining the entry as an inherent difference, even when its observed colors are accurate. “Agree, environment only” accepts the current missing-parser observation, not a permanent one-to-one exception.

| Entry | Sample and token | Decision, evidence, and fix |
| --- | --- | --- |
| 1 | CSS `utf-8`, percentages | **Disagree.** `sample.css:3` has only `meta.at-rule.header.css`; line 37 has `entity.other.keyframe-offset.percentage.css`. Neither matches a foreground rule. The percentage is scoped, contrary to the reason, but still uses the editor foreground. Private charset/keyframe captures now fix both. |
| 2 | CSS charset quotes | **Disagree.** `sample.css:3` scopes the complete quoted value as `meta.at-rule.header.css`, without a string or punctuation scope. The charset override now includes its quotes. |
| 3 | CSS plain values | **Disagree.** `sample.css:15` emits `support.constant.font-name.css`; lines 22, 29, and 31 emit `support.constant.property-value.css`. The constant rule gives orange. A private `(plain_value)` capture fixes this without changing other schemes. |
| 4 | CSS `flicker` | **Disagree.** `sample.css:36` emits `variable.parameter.keyframe-list.css`, colored orange by the constant and argument rule. `(keyframes_name)` is already a distinct node. It now has a private orange capture. |
| 5 | HTML entity punctuation | **Disagree.** `sample.html:14` emits `constant.character.entity.named.amp.html punctuation.definition.entity.html` for `&` and `;`, so [Operator, Misc] makes them grey. The entity body uses the constant rule’s orange. An inner range now separates the body from its delimiters. |
| 6 | HTML doctype `html` | **Disagree.** `sample.html:1` emits `entity.other.attribute-name.html` under `text.html.basic`, so [HTML Attributes] requires orange italics. The parent node has a distinct doctype keyword token; a guarded offset handles the ordinary HTML5 attribute. That fix is implemented. More elaborate public/system doctypes need further matching, not an inherent exception. |
| 7 | HTML-injected `document` | **Disagree.** `sample.html:23` emits `variable.other.object.js`, green through [Variables]. It has no language-variable italic. I separated ordinary builtin-looking names from true language-variable captures. The reason is also too broad: the additional `arguments` probe does have `variable.language.arguments.js`. |
| 8 | JavaScript regex flags | **Disagree.** `sample.js:39` emits `keyword.other.js`, orange through the constant rule. The capture inspector reports `@character.special.javascript` on `gi`, not a whole-literal regex capture. Codex’s orange special-character mapping already handles it. |
| 9 | JavaScript `length` | **Disagree.** `sample.js:43` emits `support.variable.property.js`, which has no matching theme rule. TextMate uses a lexical name list here, not knowledge of the receiver’s type. A name predicate fixes `length`; broader parity should follow the grammar’s property list. |
| 10 | JavaScript `console` italics | **Disagree.** `sample.js:48` emits `meta.block.js variable.other.object.js`. [Block Level Variables] gives white, and no language-variable scope adds italics. The fix is to avoid assigning the language-variable style in the first place, or reset it explicitly. Codex now matches both foreground and style. |
| 11 | Fenced JavaScript `console` | **Disagree.** `sample.md:27` emits `variable.other.object.js` without `meta.block`; [Variables] gives green without italics. The same builtin-name correction fixes this occurrence. |
| 12 | JSON depth-one keys | **Disagree.** `sample.json:10,11` have two dictionary ancestors separated by `meta.structure.dictionary.value.json` before `support.type.property-name.json`. [JSON Key - Level 1] requires green. Proposed fix: count object ancestors and select private depth captures. This remains unimplemented in Codex. |
| 13 | JSON depth-two keys | **Disagree.** `sample.json:12,13` add a third dictionary ancestor. [JSON Key - Level 2] requires `#f78c6c`. The same depth computation fixes it; array ancestors should not increase dictionary depth. This remains unimplemented. |
| 14 | JSON depth-three keys | **Disagree.** `sample.json:14,15` add a fourth dictionary ancestor. [JSON Key - Level 3] requires `#ff5370`. Implement levels zero through eight, clamping deeper keys to the most specific level-eight rule. A safely registered query predicate can count ancestors; a single stock `@property` is not a limit of the syntax tree. This remains unimplemented. |
| 15 | JSON escaped quotes | **Disagree.** `sample.json:15` emits `constant.character.escape.json`, cyan through [Escape Characters]. The base query does attach `@conceal`, but it also has a separate `escape_sequence`. Capturing anonymous quote tokens instead of coloring the conceal control fixes the ambiguity. Codex now matches. |
| 16 | JSON Unicode digits | **Disagree.** `sample.json:15` emits `constant.character.escape.json` for all of `\u00e9`. The tree’s short `escape_sequence` can be extended by four bytes after checking the adjacent content begins with four hex digits. That range correction is implemented. The supplied resolver ignores its range and therefore cannot verify it correctly. |
| 17 | Lua member names | **Disagree.** `sample.lua:12,13,18,40,41` emit `entity.other.attribute.lua` for the affected names. That scope has no matching rule; it is not an arbitrary mixture of ordinary variables. The base query already supplies `@variable.member.lua`. Codex now gives it the editor foreground. |
| 18 | Lua method receivers | **Disagree.** `sample.lua:17,30` emit `entity.name.class.lua`, gold through [Class, Support]. The tree has `method_index_expression` with a separate table field. A private capture on that field fixes both occurrences. |
| 19 | Lua `M` in `M.new` | **Disagree.** `sample.lua:10` gives `M` the `entity.name.function.lua` scope and [Function, Special Method] makes it purple. The function declaration’s dot-index table field is available to queries. Codex now captures it separately. |
| 20 | Lua library dot | **Disagree.** `sample.lua:18` scopes all of `string.format` as `support.function.library.lua`. [Function, Special Method] therefore includes the dot. A library-name predicate and dot capture now fix it. |
| 21 | Lua `in` and `goto` | **Disagree.** `sample.lua:28,32` emit `keyword.control.lua` and `keyword.control.goto.lua`. [Operator, Misc] gives grey. Explicit token captures separate these from purple `local`. Codex now matches. |
| 22 | LuaDoc `@param` | **Agree, environment only.** `sample.lua:9` emits `comment.line.double-dash.documentation.lua storage.type.annotation.lua`, so [Keyword, Storage] supplies purple and [Comment] supplies italics. The current Neovim capture is only a comment because LuaDoc parsing is unavailable. Install/load the LuaDoc parser and map its annotation capture; this is not inherently unrepresentable. |
| 23 | LuaDoc parameter name | **Agree, environment only.** `sample.lua:9` emits `entity.name.variable.lua` inside the comment. [Class, Support] supplies gold with inherited italics. The same missing-parser condition applies. A LuaDoc parameter-name capture would fix it. |
| 24 | LuaDoc type | **Agree, environment only.** `sample.lua:9` emits `support.type.lua` inside the comment. [Entity Types] supplies burnt orange with inherited italics. Load the LuaDoc parser and give that capture the type foreground while preserving the comment style. |
| 25 | Bold delimiters inside emphasis | **Disagree.** `sample.md:5,7` combine `punctuation.definition.bold.markdown` with bold/combined-emphasis scopes. [Operator, Misc] supplies grey and [Markup - Bold-Italic] specifies bold only. Private delimiter captures with `nocombine` fix the rendered result. The supplied resolver incorrectly retains italics. |
| 26 | Bold text inside italics/quotes | **Disagree.** `sample.md:5,7` activate [Markup - Bold-Italic], whose `fontStyle` is exactly `bold`. Neovim’s `nocombine` can reset the enclosing italic attribute. The screen-based check confirms the implemented correction. |
| 27 | Nested italic delimiters | **Disagree.** `sample.md:5` emits `markup.bold.markdown markup.italic.markdown punctuation.definition.italic.markdown`. [Operator, Misc] and [Markup - Bold-Italic] require grey bold delimiters. The Markdown parser’s opposite emphasis nesting can be matched explicitly. Codex now does so. |
| 28 | Heading markers | **Disagree.** `sample.md:1,3` emit `punctuation.definition.heading.markdown` beneath `markup.heading.markdown`. [Markdown - Heading] makes the markers green. The parser exposes `atx_h1_marker` through `atx_h6_marker`; private captures now distinguish them from gold text. |
| 29 | Markdown title quotes | **Disagree.** `sample.md:10` emits `punctuation.definition.string.begin.markdown` and its end counterpart. [Operator, Misc] makes them grey. The named `link_title` has anonymous quote children, now captured separately. |
| 30 | Markdown title contents | **Disagree.** `sample.md:10` emits `string.other.link.description.title.markdown`, purple through [Markdown - Link Description]. The separate `link_title` node can have a private capture even though the stock query reuses a label capture. Codex now matches. |
| 31 | Image description | **Disagree.** `sample.md:17` emits `string.other.link.description.markdown`, red through [Other Variable, String Link]. `(image_description)` is a distinct node. Codex now gives it the required foreground. |
| 32 | Supposed image brackets | **Disagree.** The actual matches are the unchecked task’s brackets at `sample.md:14`, not image brackets. The inspector emits only `meta.paragraph.markdown` there, so [Markdown - Plain] gives pale white. At line 17 image brackets do carry `punctuation.definition.link.description.*` and are grey. Codex now colors the unchecked task marker as plain prose. |
| 33 | Supposed image parentheses | **Disagree.** The actual matches are the injected JavaScript call parentheses at `sample.md:27`. Their `meta.brace.round.js` scope inherits [Markdown - Plain]. Image parentheses at line 17 instead have `punctuation.definition.metadata.markdown` and are grey. Neutral JavaScript bracket groups now preserve the fenced foreground. |
| 34 | Reference-definition brackets | **Disagree.** `sample.md:21` emits `punctuation.definition.constant.markdown`, grey through [Operator, Misc]. The `link_label` node has bracket children. Capturing them separately fixes the white-bracket error. |
| 35 | Reference label | **Disagree.** The actual occurrence is the full reference link at `sample.md:19`, not a shortcut reference. `ref` has `constant.other.reference.link.markdown`, white through [Markdown - Link Anchor]. A private `link_label` capture followed by bracket punctuation fixes it. |
| 36 | Checked task letter | **Disagree.** `sample.md:15` emits `string.other.link.title.markdown`, blue through [Markdown - Link]. An offset capture can select the middle of `(task_list_marker_checked)`. Codex now does this; the supplied resolver wrongly applies the color to its brackets as well. |
| 37 | Fence delimiters | **Disagree.** `sample.md:25,28` emit `punctuation.definition.markdown`, grey through [Operator, Misc]. `(fenced_code_block_delimiter)` is a separate node. The actual grammar does not emit the old `punctuation.definition.fenced.markdown` selector. Codex now captures the delimiter directly. |
| 38 | Autolink angles | **Disagree.** `sample.md:36` emits `punctuation.definition.link.markdown` for the angles, so [Operator, Misc] requires grey without underline. An outer punctuation capture with `nocombine`, plus an inner offset URL capture using [Markup - Underline], produces the correct rendering. |
| 39 | Thematic break | **Disagree.** `sample.md:23` emits `meta.separator.markdown`, bold muted grey through [Markdown - Separator]. `(thematic_break)` is distinct from table and quote punctuation. Codex now captures it separately. |
| 40 | Python string prefixes | **Disagree.** `sample.py:22,26` emit `storage.type.string.python`, purple through [Keyword, Storage]. The prefix shares a tree node with the quote, but offsets can separate them, including single and triple delimiters. Codex implements those ranges. |
| 41 | Python comprehension operators | **Disagree.** `sample.py:45` emits `keyword.control.flow.python`, grey through [Operator, Misc]. Ancestor checks distinguish comprehensions, and priority 110 overrides the child `is`/`not` captures inside the compound node. Codex now matches without changing ordinary `is` at line 41. |
| 42 | Python parameter `self` | **Disagree.** `sample.py:15,21` emit `variable.parameter.function.language.python variable.parameter.function.language.special.self.python`. The constant and argument rule gives orange without italics. A parameter capture with `nocombine` fixes the rendered result. |
| 43 | Python `super`, `RuntimeError` calls | **Disagree.** `sample.py:16,34` emit `support.type.python` and `support.type.exception.python`. [Entity Types] gives burnt orange. Proposed fix: restore the grammar’s builtin-type/exception classification after the broader call captures. This remains unimplemented in Codex; do not recolor all builtin calls. |
| 44 | Python decorator marker | **Disagree.** `sample.py:20,24` emit `punctuation.definition.decorator.python`, grey through [Operator, Misc]. The base query already captures `@` separately, at priority 101; it is not one indivisible attribute node. A higher-priority punctuation capture fixes it. |
| 45 | Python f-string quotes | **Disagree.** `sample.py:22` does include `punctuation.definition.string.begin.python`, but it is followed by inner `string.interpolated.python string.quoted.single.python` scopes. The inner string scope wins and gives orange through [String, Symbols, Inherited Class, Markup Heading]. The reason’s claim of no punctuation scope is inaccurate. Codex preserves the f-string quote color. |
| 46 | Python raw-string body | **Disagree.** `sample.py:26` emits `string.regexp.quoted.single.python`; [Regular Expressions] gives cyan. Proposed fix: a theme-controlled regex injection for raw-string content, using the installed regex parser, or equivalent range captures. Ordinary strings must retain orange. This remains unimplemented. |
| 47 | Python raw-string quantifier | **Disagree.** The same line emits `keyword.operator.quantifier.regexp` for `+`, purple through [Keyword, Storage]. The regex parser already supplies operator captures inside the JavaScript regex sample. The proposed raw-string injection can supply this distinction too. This remains unimplemented. |
| 48 | Python `__name__` | **Disagree.** `sample.py:50` emits `support.variable.magic.python`, which matches no foreground rule. The base capture is the dedicated `@constant.builtin` dunder heuristic, not the uppercase constant heuristic stated in the reason. Codex now restores the editor foreground for magic variable references while preserving method names. |
| 49 | TypeScript computed method name | **Disagree.** `sample.ts:28` emits `variable.other.object.ts` and `variable.other.property.ts` without `meta.block`. [Variables] gives green. Removing `class_body` from the block approximation fixes the case. Codex now matches. |
| 50 | TypeScript return `this` | **Disagree.** `sample.ts:32` emits `support.type.builtin.ts`, not the claimed primitive suffix, and [Entity Types] supplies burnt orange. `(this_type)` is directly capturable. Codex now captures it. |
| 51 | Supposed missing TSX arrow parameters | **Disagree.** The capture inspector at `sample.tsx:15` shows a `formal_parameters` node and both parameter captures on the empty `()`. Those bytes already match. The mismatches are the later call parentheses at zero-based columns 37 and 47. They have `meta.brace.round.tsx` inside `meta.tag.tsx`, so [Operator, Misc] supplies inherited grey. A JSX-context rule for call arguments now fixes them. |

Entries 32, 33, 35, and 51 particularly demonstrate why a sample-wide token-text regex is insufficient evidence. The exception can hide a different construct from the one its reason discusses. The next exception file should identify the actual line/range or grammatical context and retain the inspector evidence. A zero “unexplained” count does not establish that the exceptions are correct.

The JSON depth fix needs to count enclosing dictionaries rather than introduce a general semantic analysis dependency. A private predicate can select the corresponding depth capture. It must be registered whenever its queries can be loaded, including when switching schemes, so inactive queries cannot fail on an unknown predicate. LuaDoc needs its parser available to the harness. The Python regex proposal needs the same care about active-theme behavior as the highlight extensions. These are concrete remaining implementation choices, not claims that Treesitter lacks the necessary syntax.

**5. The comparisons are reproducible, and nothing was committed.** The required harness was run against this port before and after the changes, and against the other port. Its final nonzero exit is recorded rather than suppressed.

| Measurement | Differing characters | Unexplained runs | Mechanically excluded runs |
| --- | --- | --- | --- |
| Original Codex port, supplied resolver | 1,442 / 6,985 | 479 | 54 |
| Other port, supplied resolver | 324 / 6,985 | 0 | 93 |
| Updated Codex port, supplied resolver | 122 / 6,985 | 12 | 22 |
| Updated Codex port, actual Neovim screen | 73 / 6,985 | 0 | 13 |

“Mechanically excluded” means the sibling exception file matches the run. It is not an endorsement of that exception. The remaining rendered runs are exactly these:

| Remaining area | Characters | Runs | Status |
| --- | --- | --- | --- |
| JSON depth-one through depth-three keys | 34 | 6 | The depth computation proposed in entries 12–14 is still needed. |
| LuaDoc annotation, parameter, and type | 16 | 3 | The LuaDoc parser is unavailable in the comparison environment. |
| Python `super` and `RuntimeError` calls | 17 | 2 | The type precedence correction proposed in entry 43 is still needed. |
| Python raw regex body and quantifier | 6 | 2 | The regex parsing proposed in entries 46–47 is still needed. |

The new [screen inspector](../../../tools/compare/nvim-screen.lua) exists because the supplied resolver has two demonstrated correctness gaps. In Neovim 0.11.6, `vim.treesitter.get_captures_at_pos()` checks the node’s original range, while the real highlighter uses `vim.treesitter.get_range(node, buffer, metadata[capture])`. The resolver consequently ignores `#offset!`. It also accumulates style booleans without honoring `nocombine`. The actual renderer supports that style reset. The screen inspector reads the rendered cells, verifies their text against the source, and writes the same foreground/bold/italic/underline run format. It additionally records strikethrough, although the unchanged `diff.mjs` does not compare that field.

All 12 final unexplained resolver runs disappear on the actual screen: three doctype punctuation/keyword runs acquire spurious italics from the ignored attribute range; two triple-emphasis delimiter runs retain spurious italics; two checked-task brackets acquire the letter’s blue foreground; two parameter `self` runs retain spurious italics; and three Python quote runs acquire their prefixes’ purple foreground. Some false positives also happen to match existing exceptions, such as the Unicode escape suffix and autolink angles. Those are further reasons to compare actual rendered ranges and styles before accepting an exception.

The screen helper is verification tooling, not colorscheme startup code. It uses Neovim’s internal `nvim__inspect_cell` inspection API and was checked on 0.11.6. It expects these small ASCII fixtures to fit its 160-column, 80-line screen and asserts if the displayed text does not match. Conceal is disabled for the token-color comparison. It does not test semantic tokens, renderer plugins, or every possible program in each language.

From the Codex checkout, these commands reproduce the two final measurements:

```sh
NVIM_LOG_FILE=/tmp/spooky-compare-nvim.log \
  ../spooky-scary-color-theme/tools/compare/run.sh "$PWD" codex

SPOOKY_SAMPLE_DIR="$PWD/../spooky-scary-color-theme/tools/compare/samples" \
SPOOKY_OUT_DIR=/tmp/spooky-codex-screen \
NVIM_LOG_FILE=/tmp/spooky-screen-nvim.log \
  script -q /tmp/spooky-screen-terminal.log \
  nvim --clean -n -i NONE \
  -c 'luafile tools/compare/nvim-screen.lua' -c 'qa!' >/dev/null

node ../spooky-scary-color-theme/tools/compare/diff.mjs /tmp/spooky-codex-screen
```

For the cross-scheme check, the same inspector accepts `SPOOKY_COLORSCHEME=default` and `SPOOKY_PORT_DIR`. I compared visible cells from an empty query directory with cells from each checkout’s runtime path. The private queries changed zero visible cells; the sibling queries changed 446. Switching from Spooky Scary to the default scheme was also checked to ensure private highlights do not remain active.

The ordinary headless colorscheme load exits zero without output. The sibling palette check exits zero, and this port’s palette was not changed. All ten added highlight query files parse successfully with the installed parsers, and all nine supplied samples render successfully. `git diff --check` passes. I inspected the complete modified and added-file diff and removed generated Neovim log changes. The shared samples, theme JSON, sibling implementation, sibling harness scripts, and sibling exception file were not edited.

The implementation changes are limited to [Treesitter highlight mappings](../../../lua/spooky-scary/groups/treesitter.lua), [private query extensions](../../../queries), and the screen inspector required to verify the range/style corrections. The recorded plugin and remaining parser/depth issues have not been silently declared equivalent.

Agreement is withheld. The largest remaining measured issue is the JSON key-depth mapping, and the other port’s exception list still includes many ordinary implementation gaps.

[Comment]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L130
[Variables]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L141
[Keyword, Storage]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L170
[Operator, Misc]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L181
[Tag]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L202
[Function, Special Method]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L214
[Block Level Variables]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L228
[Other Variable, String Link]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L238
[Number, Constant, Function Argument, Tag Attribute, Embedded]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L248
[String, Symbols, Inherited Class, Markup Heading]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L265
[Class, Support]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L281
[Entity Types]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L297
[HTML Attributes]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L373
[Regular Expressions]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L430
[Escape Characters]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L439
[Decorators]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L459
[JSON Key - Level 1]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L489
[JSON Key - Level 2]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L499
[JSON Key - Level 3]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L508
[Markdown - Plain]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L562
[Markdown - Heading]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L590
[Markup - Italic]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L601
[Markup - Bold]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L611
[Markup - Bold-Italic]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L622
[Markup - Underline]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L637
[Markup - Quote]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L656
[Markdown - Link]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L665
[Markdown - Link Description]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L674
[Markdown - Link Anchor]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L683
[Markup - Raw Block]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L692
[Markdown - Separator]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L739
[Markup - Table]: ../../../themes/Spooky%20Scary%20Color%20Theme-color-theme.json#L749
