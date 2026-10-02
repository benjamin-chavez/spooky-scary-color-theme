local p = require("spooky-scary.palette")

local function mode(color)
  return {
    a = { fg = p.statusBarBackground, bg = color, gui = "bold" },
    b = { fg = color, bg = p.tabActiveBackground },
    c = { fg = p.statusBarForeground, bg = p.statusBarBackground },
  }
end

return {
  normal = mode(p.focusBorder),
  insert = mode(p.foreground),
  visual = mode(p.textLinkForeground),
  replace = mode(p.textLinkActiveForeground),
  command = mode(p.number),
  terminal = mode(p.foreground),
  inactive = {
    a = { fg = p.statusBarForeground, bg = p.statusBarBackground },
    b = { fg = p.statusBarForeground, bg = p.statusBarBackground },
    c = { fg = p.statusBarForeground, bg = p.statusBarBackground },
  },
}
