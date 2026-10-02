-- Renders a sample with Neovim's own :TOhtml and compare per-character colors
-- against the harness resolver output, to validate the resolver's combine logic.
local root = "/Users/benjaminchavez/Code/spooky-scary-color-theme"
vim.opt.rtp:prepend(vim.fn.expand("~/.local/share/nvim/lazy/nvim-treesitter"))
vim.opt.rtp:prepend(root)
require("nvim-treesitter.query_predicates")
vim.o.termguicolors = true
vim.cmd("colorscheme spooky-scary")
local sample = arg[1]
vim.cmd("edit " .. root .. "/tools/compare/samples/" .. sample)
local lang = ({js="javascript",ts="typescript",tsx="tsx",html="html",css="css",json="json",md="markdown",py="python",lua="lua"})[sample:match("%.(%w+)$")]
vim.treesitter.start(0, lang)
vim.treesitter.get_parser(0, lang):parse(true)
local html = require("tohtml").tohtml(0, { number_lines = false })
vim.fn.writefile(html, root .. "/tools/compare/out/tohtml-" .. sample .. ".html")
print("wrote tohtml for " .. sample .. " (" .. #html .. " lines)")
