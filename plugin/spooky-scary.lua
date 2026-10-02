-- Registers the query predicate used by queries/json/highlights.scm. It must exist whenever
-- those queries can load, including under another colorscheme, so it lives in plugin/.
if vim.g.loaded_spooky_scary_predicates then
  return
end
vim.g.loaded_spooky_scary_predicates = true

-- (#spooky-json-depth? @capture N) matches when the node has exactly N enclosing JSON
-- objects beyond the outermost one, or at least N when N is 8. Arrays do not count, which
-- mirrors how the theme's descendant selectors skip intermediate scopes.
vim.treesitter.query.add_predicate("spooky-json-depth?", function(match, _, _, predicate)
  local nodes = match[predicate[2]]
  if type(nodes) ~= "table" then
    nodes = { nodes }
  end
  local wanted = tonumber(predicate[3])
  local node = nodes[1]
  if not node or not wanted then
    return false
  end
  local depth = -1
  local parent = node:parent()
  while parent do
    if parent:type() == "object" then
      depth = depth + 1
    end
    parent = parent:parent()
  end
  if wanted >= 8 then
    return depth >= 8
  end
  return depth == wanted
end, { force = true, all = true })
