# Brief for the Codex port

You are porting the VS Code color theme in `themes/Spooky Scary Color Theme-color-theme.json`
to a Neovim colorscheme, written fresh, in this repository. Another engineer is writing an
independent port of the same theme from the same brief. Afterwards the two ports are
reconciled against a harness that diffs VS Code's own tokenizer output against Neovim's
resolved highlights, so aim for a one-to-one color match, not a tasteful reinterpretation.

Read `docs/superpowers/specs/2026-10-02-nvim-port-design.md` first. Follow its file layout
exactly, because the harness loads the port by adding this directory to `runtimepath` and
running `colorscheme spooky-scary`:

- `colors/spooky-scary.lua`
- `lua/spooky-scary/init.lua`
- `lua/spooky-scary/palette.lua`
- `lua/spooky-scary/groups/editor.lua`, `syntax.lua`, `treesitter.lua`, `plugins.lua`
- `lua/lualine/themes/spooky-scary.lua`

Rules:

- Every color comes from the theme JSON. Eight-digit colors with alpha are blended over
  `editor.background` (`#23242b`) with standard source-over compositing and rounded to
  the nearest integer per channel.
- VS Code resolves two TextMate rules of equal specificity by taking the later one in the
  file. Descendant selectors such as `meta.block variable.other` are more specific than
  single scopes. Tokens matching no rule take `editor.foreground` (`#a361ff`).
- The theme has no `semanticHighlighting` key, so VS Code uses TextMate only. Clear the
  `@lsp.*` groups so semantic tokens do not override treesitter.
- Map workbench colors to core UI groups and to these plugins: lualine, bufferline,
  nvim-tree, telescope, gitsigns, nvim-cmp, indent-blankline, which-key, render-markdown,
  todo-comments.
- Treesitter queries are installed at `~/.local/share/nvim/lazy/nvim-treesitter/queries`.
  Read the `highlights.scm` for javascript, ecma, jsx, typescript, tsx, html, html_tags, css,
  json, markdown, markdown_inline, python and lua to learn the capture names before you
  decide the mapping. Use language-suffixed captures like `@tag.attribute.html` where the
  theme has a language-specific rule.
- Do not read or copy any other Neovim theme and do not look at `~/.config/nvim`.
- Verify the colorscheme loads:
  `nvim --headless --clean --cmd "set rtp+=$PWD" -c "colorscheme spooky-scary" -c q`
  must exit 0 with no output.
- Commit your work on the current branch with clear messages. Finish by writing
  `docs/superpowers/specs/2026-10-02-nvim-port-codex-notes.md` listing every mapping
  decision you were unsure about and why you chose what you chose.
