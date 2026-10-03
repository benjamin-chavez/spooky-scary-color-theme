-- Run with: nvim --headless --clean -l tools/compare/nvim-tokens.lua
-- Loads the port, opens each sample, and writes per-character resolved colors to out/nvim.
-- Env: SPOOKY_PORT_DIR (default repo root), NVIM_TREESITTER_DIR, SPOOKY_OUT_DIR.
local script_path = debug.getinfo(1, "S").source:sub(2)
local here = vim.fs.dirname(vim.fs.normalize(vim.fn.fnamemodify(script_path, ":p")))
local repo_root = vim.fs.normalize(here .. "/../..")
local port_dir = vim.env.SPOOKY_PORT_DIR or repo_root
local treesitter_dir = vim.env.NVIM_TREESITTER_DIR
  or vim.fn.expand("~/.local/share/nvim/lazy/nvim-treesitter")
local out_dir = vim.env.SPOOKY_OUT_DIR or (here .. "/out/nvim")
local samples_dir = here .. "/samples"

vim.opt.runtimepath:prepend(treesitter_dir)
vim.opt.runtimepath:prepend(port_dir)
-- Markdown injections use directives that nvim-treesitter registers in this module.
require("nvim-treesitter.query_predicates")
-- plugin/ files are only sourced at startup, so load the port's predicate explicitly.
vim.cmd("runtime! plugin/spooky-scary.lua")
vim.o.termguicolors = true
vim.cmd("colorscheme spooky-scary")

local lang_by_extension = {
  js = "javascript", ts = "typescript", tsx = "tsx", html = "html", css = "css",
  json = "json", md = "markdown", py = "python", lua = "lua",
}

local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })

local function hex(color)
  return string.format("#%06x", color)
end

-- Mirrors how Neovim combines overlapping treesitter extmarks: higher priority wins,
-- later captures win ties, colors override and style flags accumulate.
local function resolve(buf, row, col)
  local captures = vim.treesitter.get_captures_at_pos(buf, row, col)
  local ordered = {}
  for index, capture in ipairs(captures) do
    local priority = tonumber(capture.metadata and capture.metadata.priority) or 100
    ordered[#ordered + 1] = { index = index, capture = capture, priority = priority }
  end
  table.sort(ordered, function(a, b)
    if a.priority ~= b.priority then return a.priority < b.priority end
    return a.index < b.index
  end)
  local attrs = { fg = normal.fg, b = false, i = false, u = false }
  for _, entry in ipairs(ordered) do
    local name = entry.capture.capture
    if name:sub(1, 1) ~= "_" then
      local group = "@" .. name .. "." .. entry.capture.lang
      local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
      if hl.fg then attrs.fg = hl.fg end
      if hl.bold then attrs.b = true end
      if hl.italic then attrs.i = true end
      if hl.underline then attrs.u = true end
    end
  end
  return attrs
end

local function same(a, b)
  return a.fg == b.fg and a.b == b.b and a.i == b.i and a.u == b.u
end

local function dump_sample(name)
  local extension = name:match("%.(%w+)$")
  local lang = lang_by_extension[extension]
  if not lang then return nil end
  local lines = vim.fn.readfile(samples_dir .. "/" .. name)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = vim.filetype.match({ filename = name }) or lang
  vim.treesitter.start(buf, lang)
  vim.treesitter.get_parser(buf, lang):parse(true)

  local out_lines = {}
  for row, text in ipairs(lines) do
    local runs = {}
    local current = nil
    for col = 0, #text - 1 do
      local attrs = resolve(buf, row - 1, col)
      if current and same(current, attrs) then
        current.e = col + 1
      else
        current = { s = col, e = col + 1, fg = attrs.fg, b = attrs.b, i = attrs.i, u = attrs.u }
        runs[#runs + 1] = current
      end
    end
    for _, run in ipairs(runs) do
      run.fg = hex(run.fg)
    end
    out_lines[#out_lines + 1] = { text = text, runs = runs }
  end
  vim.api.nvim_buf_delete(buf, { force = true })
  return { sample = name, lines = out_lines }
end

vim.fn.mkdir(out_dir, "p")
local names = vim.fn.readdir(samples_dir)
table.sort(names)
for _, name in ipairs(names) do
  local result = dump_sample(name)
  if result then
    vim.fn.writefile({ vim.json.encode(result) }, out_dir .. "/" .. name .. ".json")
    io.stdout:write(string.format("nvim    %s: %d lines\n", name, #result.lines))
  end
end
