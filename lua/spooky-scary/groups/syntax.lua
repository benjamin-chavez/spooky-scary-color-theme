local p = require("spooky-scary.palette")

return {
  Comment = { fg = p.comment, italic = true },
  SpecialComment = { link = "Comment" },

  Identifier = { fg = p.variable },
  Function = { fg = p.func },

  Constant = { fg = p.number },
  Number = { link = "Constant" },
  Float = { link = "Constant" },
  Boolean = { link = "Constant" },
  Character = { link = "Constant" },
  String = { fg = p.string },
  SpecialChar = { fg = p.escape },

  Keyword = { fg = p.keyword },
  Statement = { link = "Keyword" },
  Operator = { link = "Keyword" },
  StorageClass = { link = "Keyword" },
  Structure = { link = "Keyword" },
  Typedef = { link = "Keyword" },

  -- Control flow and imports are keyword.control in every bundled grammar, which the theme paints grey.
  Conditional = { fg = p.operatorMisc },
  Repeat = { link = "Conditional" },
  Exception = { link = "Conditional" },
  Label = { link = "Conditional" },
  Include = { link = "Conditional" },
  PreProc = { link = "Conditional" },
  Define = { link = "Conditional" },
  Macro = { link = "Conditional" },
  PreCondit = { link = "Conditional" },

  Type = { fg = p.classSupport },

  Delimiter = { fg = p.operatorMisc },
  Special = { link = "Delimiter" },
  Debug = { link = "Delimiter" },

  Tag = { fg = p.tag },

  Error = { fg = p.invalid },
  Todo = { fg = p.editorBackground, bg = p.foreground, bold = true },
  Underlined = { fg = p.textLinkForeground, underline = true },
  Ignore = { fg = p.editorBackground },

  diffAdded = { fg = p.inserted },
  diffRemoved = { fg = p.deleted },
  diffChanged = { fg = p.changed },
  diffFile = { fg = p.func },
  diffLine = { fg = p.textLinkForeground },
  diffIndexLine = { fg = p.statusBarForeground },
  helpCommand = { fg = p.number },
  helpExample = { fg = p.markdownPlain },
}
