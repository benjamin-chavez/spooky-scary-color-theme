-- Headless check of the ghost module: nvim --headless --clean -l tools/haunt-smoke.lua (run from the repo root)
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.o.termguicolors = true
vim.cmd("colorscheme spooky-scary")
local haunt = require("spooky-scary.haunt")
-- Capture terminal writes instead of emitting them.
local written = {}
vim.api.nvim_chan_send = function(_, s) written[#written + 1] = s end
haunt.setup({ frequency = 3, graphics = "kitty" })
local meta = dofile("assets/ghost/frames.lua")
local frame_count = #meta.frames
assert(frame_count >= 8, "expected the visible ghost frames")
vim.cmd("enew")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "", "", "", "hello" })
vim.api.nvim_win_set_cursor(0, { 4, 5 })
-- Three keystrokes through the autocmd path trigger the haunt.
for _ = 1, 3 do vim.api.nvim_exec_autocmds("InsertCharPre", {}) end
vim.wait(1000, function() return false end, 50)
local all = table.concat(written)
assert(#meta.colors >= 10, "expected a tint set per token color")
local transmits = select(2, all:gsub("a=t,t=d,f=100", ""))
local places = select(2, all:gsub("a=p,i=", ""))
local deletes = select(2, all:gsub("a=d,d=i", ""))
print(string.format("kitty path: %d transmits, %d placements, %d deletes, %d bytes", transmits, places, deletes, #all))
assert(transmits == frame_count and places == frame_count and deletes == frame_count)
assert(all:find("\27_G", 1, true) and all:find("\27\\", 1, true), "APC framing")
-- Text fallback: a float appears and goes away.
written = {}
haunt.setup({ frequency = 1, graphics = "text" })
vim.api.nvim_exec_autocmds("InsertCharPre", {})
local saw_float = false
vim.wait(1500, function()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(w).relative ~= "" then saw_float = true end
  end
  return false
end, 20)
local floats = 0
for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(w).relative ~= "" then floats = floats + 1 end end
print(string.format("text path: float seen=%s, floats left=%d, terminal bytes=%d", tostring(saw_float), floats, #table.concat(written)))
assert(saw_float and floats == 0 and #table.concat(written) == 0)
print("haunt smoke ok")

-- Color selection: with the cursor on a Lua string the tint set differs from the plain-text one.
written = {}
vim.api.nvim_chan_send = function(_, s) written[#written + 1] = s end
haunt.setup({ frequency = 1, graphics = "kitty" })
vim.opt.rtp:prepend(vim.fn.expand("~/.local/share/nvim/lazy/nvim-treesitter"))
vim.cmd("enew")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "", "local greeting = 'boo'" })
vim.bo.filetype = "lua"
vim.treesitter.start(0, "lua")
vim.treesitter.get_parser(0, "lua"):parse(true)
vim.api.nvim_win_set_cursor(0, { 2, 20 })
vim.api.nvim_exec_autocmds("InsertCharPre", {})
vim.wait(1000, function() return false end, 50)
local on_string = table.concat(written):match("a=p,i=(%d+)")
written = {}
vim.api.nvim_win_set_cursor(0, { 2, 8 })
vim.api.nvim_exec_autocmds("InsertCharPre", {})
vim.wait(1000, function() return false end, 50)
local on_variable = table.concat(written):match("a=p,i=(%d+)")
print(string.format("tint sets: string token -> id %s, variable token -> id %s", on_string, on_variable))
assert(on_string and on_variable and math.floor(on_string / 100) ~= math.floor(on_variable / 100), "different tokens should pick different tint sets")
print("color selection ok")
