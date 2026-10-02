local M = {}

local function apply(groups)
  for name, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, name, spec)
  end
end

function M.load()
  if vim.fn.has("termguicolors") == 0 then
    error("spooky-scary requires a Neovim build with termguicolors")
  end
  vim.cmd("highlight clear")
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "spooky-scary"

  apply(require("spooky-scary.groups.editor"))
  apply(require("spooky-scary.groups.syntax"))
  apply(require("spooky-scary.groups.treesitter"))
  apply(require("spooky-scary.groups.plugins"))
end

return M
