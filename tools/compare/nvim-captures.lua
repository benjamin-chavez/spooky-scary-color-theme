-- Debug helper: prints the treesitter captures and resolved color for each run on one line.
-- Usage: nvim --headless --clean -l tools/compare/nvim-captures.lua sample.css 14
local script_path = debug.getinfo(1, "S").source:sub(2)
local here = vim.fs.dirname(vim.fs.normalize(vim.fn.fnamemodify(script_path, ":p")))
local repo_root = vim.fs.normalize(here .. "/../..")
local port_dir = vim.env.SPOOKY_PORT_DIR or repo_root
local treesitter_dir = vim.env.NVIM_TREESITTER_DIR
  or vim.fn.expand("~/.local/share/nvim/lazy/nvim-treesitter")
vim.opt.runtimepath:prepend(treesitter_dir)
vim.opt.runtimepath:prepend(port_dir)
require("nvim-treesitter.query_predicates")
-- plugin/ files are only sourced at startup, so load the port's predicate explicitly.
vim.cmd("runtime! plugin/spooky-scary.lua")
vim.o.termguicolors = true
vim.cmd("colorscheme spooky-scary")

local sample, line_number = arg[1], tonumber(arg[2])
local lang_by_extension = {
  js = "javascript", ts = "typescript", tsx = "tsx", html = "html", css = "css",
  json = "json", md = "markdown", py = "python", lua = "lua",
}
local lang = lang_by_extension[sample:match("%.(%w+)$")]
local lines = vim.fn.readfile(here .. "/samples/" .. sample)
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
vim.treesitter.start(buf, lang)
vim.treesitter.get_parser(buf, lang):parse(true)

local text = lines[line_number]
local previous, start = nil, 0
local function flush(stop)
  if previous == nil then return end
  local names = {}
  for _, c in ipairs(previous) do
    names[#names + 1] = "@" .. c.capture .. "." .. c.lang
      .. (c.metadata and c.metadata.priority and ("(p" .. c.metadata.priority .. ")") or "")
  end
  io.stdout:write(string.format("%-24s %s\n", vim.json.encode(text:sub(start + 1, stop)), table.concat(names, " ")))
end
for col = 0, #text - 1 do
  local caps = vim.treesitter.get_captures_at_pos(buf, line_number - 1, col)
  local key = vim.inspect(vim.tbl_map(function(c) return c.capture .. c.lang end, caps))
  if previous == nil or key ~= previous.key then
    flush(col)
    previous = caps
    previous.key = key
    start = col
  end
end
flush(#text)
