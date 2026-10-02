local p = require("spooky-scary.palette")

local groups = {
  ["@comment"] = { link = "Comment" },
  ["@comment.documentation"] = { link = "Comment" },
  ["@comment.error"] = { fg = p.invalid, italic = true },
  ["@comment.warning"] = { fg = p.number, italic = true },
  ["@comment.todo"] = { link = "Todo" },
  ["@comment.note"] = { fg = p.textLinkForeground, italic = true },

  ["@variable"] = { link = "Identifier" },
  ["@variable.builtin"] = { fg = p.languageVariable, italic = true },
  ["@variable.parameter"] = { fg = p.number },
  ["@variable.parameter.builtin"] = { fg = p.number },
  ["@variable.member"] = { link = "Identifier" },

  ["@constant"] = { link = "Constant" },
  ["@constant.builtin"] = { link = "Constant" },
  ["@constant.macro"] = { link = "Constant" },
  ["@module"] = { fg = p.classSupport },
  ["@module.builtin"] = { fg = p.classSupport },
  ["@label"] = { link = "Label" },

  ["@string"] = { link = "String" },
  ["@string.documentation"] = { link = "String" },
  ["@string.regexp"] = { fg = p.regexp },
  ["@string.escape"] = { fg = p.escape },
  ["@string.special"] = { link = "String" },
  ["@string.special.symbol"] = { link = "String" },
  ["@string.special.url"] = { fg = p.textLinkForeground, underline = true },
  ["@string.special.path"] = { link = "String" },
  ["@character"] = { link = "Character" },
  ["@character.special"] = { link = "SpecialChar" },
  ["@boolean"] = { link = "Boolean" },
  ["@number"] = { link = "Number" },
  ["@number.float"] = { link = "Float" },

  ["@type"] = { link = "Type" },
  ["@type.builtin"] = { fg = p.entityType },
  ["@type.definition"] = { link = "Type" },
  ["@type.qualifier"] = { link = "Keyword" },
  ["@attribute"] = { fg = p.decorator, italic = true },
  ["@attribute.builtin"] = { fg = p.decorator, italic = true },
  ["@property"] = { link = "Identifier" },

  ["@function"] = { link = "Function" },
  ["@function.builtin"] = { link = "Function" },
  ["@function.call"] = { link = "Function" },
  ["@function.macro"] = { link = "Function" },
  ["@function.method"] = { link = "Function" },
  ["@function.method.call"] = { link = "Function" },
  ["@constructor"] = { fg = p.classSupport },
  ["@operator"] = { link = "Operator" },

  ["@keyword"] = { link = "Keyword" },
  ["@keyword.coroutine"] = { link = "Keyword" },
  ["@keyword.function"] = { link = "Keyword" },
  ["@keyword.operator"] = { link = "Keyword" },
  ["@keyword.import"] = { link = "Include" },
  ["@keyword.type"] = { link = "Keyword" },
  ["@keyword.modifier"] = { link = "Keyword" },
  ["@keyword.repeat"] = { link = "Repeat" },
  ["@keyword.return"] = { link = "Conditional" },
  ["@keyword.debugger"] = { link = "Conditional" },
  ["@keyword.exception"] = { link = "Exception" },
  ["@keyword.conditional"] = { link = "Conditional" },
  ["@keyword.conditional.ternary"] = { link = "Operator" },
  ["@keyword.directive"] = { link = "PreProc" },
  ["@keyword.directive.define"] = { link = "Define" },

  ["@punctuation.delimiter"] = { link = "Delimiter" },
  ["@punctuation.bracket"] = { link = "Delimiter" },
  ["@punctuation.special"] = { link = "Delimiter" },

  ["@markup.strong"] = { fg = p.markupBold, bold = true },
  ["@markup.italic"] = { fg = p.markupItalic, italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.underline"] = { fg = p.markupUnderline, underline = true },
  ["@markup.heading"] = { fg = p.markdownHeading },
  ["@markup.heading.1"] = { link = "@markup.heading" },
  ["@markup.heading.2"] = { link = "@markup.heading" },
  ["@markup.heading.3"] = { link = "@markup.heading" },
  ["@markup.heading.4"] = { link = "@markup.heading" },
  ["@markup.heading.5"] = { link = "@markup.heading" },
  ["@markup.heading.6"] = { link = "@markup.heading" },
  ["@markup.quote"] = { italic = true },
  ["@markup.math"] = { fg = p.markdownPlain },
  ["@markup.link"] = { fg = p.markdownLinkAnchor },
  ["@markup.link.label"] = { fg = p.markdownLink },
  ["@markup.link.url"] = { fg = p.markdownPlain, underline = true },
  ["@markup.raw"] = { fg = p.markdownRawInline },
  ["@markup.raw.block"] = { fg = p.markdownPlain },
  ["@markup.list"] = { fg = p.markdownPlain },
  ["@markup.list.checked"] = { fg = p.inserted },
  ["@markup.list.unchecked"] = { fg = p.markdownPlain },

  ["@diff.plus"] = { fg = p.inserted },
  ["@diff.minus"] = { fg = p.deleted },
  ["@diff.delta"] = { fg = p.changed },

  ["@tag"] = { link = "Tag" },
  ["@tag.builtin"] = { link = "Tag" },
  ["@tag.attribute"] = { fg = p.attribute },
  ["@tag.delimiter"] = { fg = p.operatorMisc },

  -- HTML: attributes are italic orange only inside text.html.basic.
  ["@tag.attribute.html"] = { fg = p.htmlAttribute, italic = true },

  -- CSS: property names, class selectors, units.
  ["@property.css"] = { fg = p.cssProperty },
  ["@type.css"] = { fg = p.cssClass },
  ["@constant.css"] = { fg = p.cssId },
  ["@string.css"] = { fg = p.string },
  ["@tag.css"] = { fg = p.tag },
  ["@attribute.css"] = { fg = p.attribute },

  -- JSON: level 0 keys. Deeper levels are a known difference.
  ["@property.json"] = { fg = p.jsonKey0 },

  -- Markdown: plain text is the Material near-white, not the editor purple.
  ["@markup.heading.markdown"] = { fg = p.markdownHeading },
  ["@punctuation.special.markdown"] = { fg = p.markdownHeading },
  ["@punctuation.delimiter.markdown"] = { fg = p.markdownMuted },
  ["@markup.raw.block.markdown"] = { fg = p.markdownPlain },
  ["@label.markdown"] = { fg = p.markdownMuted },
  ["@markup.quote.markdown"] = { fg = p.markdownPlain, italic = true },
  ["@markup.list.markdown"] = { fg = p.markdownPlain },
  ["@markup.link.label.markdown_inline"] = { fg = p.markdownLink },
  ["@markup.link.markdown_inline"] = { fg = p.markdownLinkAnchor },
  ["@markup.link.url.markdown_inline"] = { fg = p.markdownPlain, underline = true },
  ["@markup.raw.markdown_inline"] = { fg = p.markdownRawInline },
  ["@string.escape.markdown_inline"] = { fg = p.escape },
}

-- Clear LSP semantic token groups so treesitter colors win, as in VS Code with this theme.
for _, name in ipairs({
  "@lsp.type.class", "@lsp.type.comment", "@lsp.type.decorator", "@lsp.type.enum",
  "@lsp.type.enumMember", "@lsp.type.event", "@lsp.type.function", "@lsp.type.interface",
  "@lsp.type.keyword", "@lsp.type.macro", "@lsp.type.method", "@lsp.type.modifier",
  "@lsp.type.namespace", "@lsp.type.number", "@lsp.type.operator", "@lsp.type.parameter",
  "@lsp.type.property", "@lsp.type.regexp", "@lsp.type.string", "@lsp.type.struct",
  "@lsp.type.type", "@lsp.type.typeParameter", "@lsp.type.variable",
  "@lsp.mod.deprecated", "@lsp.mod.readonly", "@lsp.mod.defaultLibrary",
}) do
  groups[name] = {}
end

return groups
