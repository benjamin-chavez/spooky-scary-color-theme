local M = {}

local function hex_to_rgb(hex)
  return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

-- VS Code composites alpha colors over the editor background. Neovim has no alpha, so
-- this returns the opaque color VS Code actually paints.
function M.blend(rgba, background)
  local alpha = tonumber(rgba:sub(8, 9), 16) / 255
  local r, g, b = hex_to_rgb(rgba)
  local br, bg, bb = hex_to_rgb(background)
  local function mix(fg, back)
    return math.floor(back + (fg - back) * alpha + 0.5)
  end
  return string.format("#%02x%02x%02x", mix(r, br), mix(g, bg), mix(b, bb))
end

-- Workbench colors, named by the VS Code key they come from.
M.editorBackground = "#23242b"
M.editorForeground = "#a361ff"
M.focusBorder = "#894fe0"
M.foreground = "#90f078"
M.iconForeground = "#894fe0"
M.textLinkForeground = "#b184dd"
M.textLinkActiveForeground = "#ff9018"
M.buttonBackground = "#b184dd"
M.buttonHoverBackground = "#8e66b6"
M.scrollbarSliderBackground = "#894fe0"
M.scrollbarSliderHoverBackground = M.blend("#90f078cb", M.editorBackground)
M.activityBarBackground = "#1c1e22"
M.activityBarBadgeBackground = "#1f2225"
M.sideBarBackground = "#1c1e22"
M.sideBarSectionHeaderForeground = "#ab77f8"
M.editorGroupBorder = "#ffffff"
M.editorGroupDropBackground = M.blend("#90f07823", M.editorBackground)
M.tabsBackground = "#1e1e25"
M.tabActiveBackground = "#1e1e25"
M.tabInactiveBackground = "#19191f"
M.tabActiveForeground = "#b184dd"
M.lineNumberActiveForeground = "#90f078"
M.cursor = "#90f078"
M.selectionBackground = M.blend("#9a66e92a", M.editorBackground)
M.selectionForeground = "#894fe0"
M.findMatchBackground = "#888888"
M.menuBackground = "#1b1d20"
M.menuSelectionBackground = "#b184dd"
M.menubarSelectionForeground = "#90f078"
M.editorErrorForeground = "#ffffff"
M.statusBarBackground = "#1b1d20"
M.statusBarForeground = "#808080"
M.breadcrumbForeground = "#894fe0"
M.breadcrumbFocusForeground = "#90f078"
M.gitConflicting = "#ff7300"

-- Token colors, named by the tokenColors rule they come from.
M.comment = M.blend("#9bfa8e91", M.editorBackground)
M.variable = "#90f078"
M.colorConstant = "#ffffff"
M.invalid = "#ff7300"
M.keyword = "#894fe0"
M.operatorMisc = "#afafaf"
M.tag = "#90f078"
M.func = "#b184dd"
M.blockVariable = "#d8d8d8"
M.otherVariable = "#f07178"
M.number = "#fca03f"
M.string = "#fca03f"
M.classSupport = "#FFCB6B"
M.entityType = "#F17008"
M.cssProperty = "#fca03f"
M.subMethod = "#FF5370"
M.languageVariable = "#894fe0"
M.jsMethod = "#82AAFF"
M.attribute = "#C792EA"
M.htmlAttribute = "#fca03f"
M.cssClass = "#c8a9f7"
M.cssId = "#ffffff"
M.inserted = "#C3E88D"
M.deleted = "#FF5370"
M.changed = "#C792EA"
M.regexp = "#89DDFF"
M.escape = "#89DDFF"
M.decorator = "#82AAFF"
M.jsonKey0 = "#C792EA"
M.jsonKey1 = "#90f078"
M.jsonKey2 = "#F78C6C"
M.jsonKey3 = "#FF5370"
M.jsonKey4 = "#C17E70"
M.jsonKey5 = "#82AAFF"
M.jsonKey6 = "#f07178"
M.jsonKey7 = "#C792EA"
M.jsonKey8 = "#C3E88D"
M.markdownPlain = "#EEFFFF"
M.markdownRawInline = "#C792EA"
M.markdownMuted = "#65737E"
M.markdownHeading = "#C3E88D"
M.markupItalic = "#f07178"
M.markupBold = "#fab56b"
M.markupUnderline = "#F78C6C"
M.markdownLink = "#82AAFF"
M.markdownLinkDescription = "#C792EA"
M.markdownLinkAnchor = "#ffffff"
M.markdownFence = M.blend("#00000050", M.editorBackground)

return M
