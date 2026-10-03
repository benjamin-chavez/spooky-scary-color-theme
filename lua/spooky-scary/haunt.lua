-- A ghost rises out of the cursor line every N keystrokes, like the Power Mode setup in the
-- README: a small purple silhouette, about one cell tall, gone in a quarter second. In a
-- terminal that speaks the Kitty graphics protocol (Ghostty, Kitty, WezTerm) it plays the
-- README's ghost GIF frames; elsewhere it animates a glyph that rises and fades.
local M = {}

local palette = require("spooky-scary.palette")

local defaults = {
  frequency = 20,
  frame_ms = nil, -- defaults to the GIF's own timing from assets/ghost/frames.lua
  columns = 3, -- width of the image ghost in terminal cells; 3 by 1 keeps the frames' aspect
  rows = 1, -- height of the image ghost in terminal cells
  column_offset = -2, -- cells left of the cursor where the ghost box starts, so it rises over the last typed characters
  graphics = "auto", -- "auto", "kitty" or "text"
}

local state = {
  options = nil,
  keystrokes = 0,
  playing = false,
  frames = nil,
  transmitted = false,
  augroup = nil,
}

local asset_dir = vim.fs.normalize(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/../../assets/ghost")

local function load_frames()
  if state.frames then
    return state.frames
  end
  local ok, meta = pcall(dofile, asset_dir .. "/frames.lua")
  if not ok then
    return nil
  end
  state.frames = meta
  return meta
end

-- Terminal support. The protocol query handshake needs a UI round trip, so this relies on
-- the environment variables the supporting terminals set.
local function kitty_supported()
  if state.options.graphics == "text" then
    return false
  end
  if state.options.graphics == "kitty" then
    return true
  end
  if vim.env.TMUX then
    return false
  end
  return vim.env.KITTY_WINDOW_ID ~= nil
    or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
    or vim.env.TERM_PROGRAM == "ghostty"
    or vim.env.TERM_PROGRAM == "WezTerm"
    or (vim.env.TERM or ""):match("kitty") ~= nil
end

-- v:stderr is the channel Neovim documents for sending escape sequences to the host terminal.
local function write_terminal(data)
  vim.api.nvim_chan_send(vim.v.stderr, data)
end

local function graphics_command(control, payload)
  return "\27_G" .. control .. (payload and (";" .. payload) or "") .. "\27\\"
end

-- Image ids are arbitrary but must not collide with other plugins; 7777 leaves room for frames.
local IMAGE_ID_BASE = 7777

-- Sends every frame once as PNG data in 4096-byte chunks. q=2 suppresses terminal replies,
-- which would otherwise land in Neovim's input.
local function transmit_frames(meta)
  for index, name in ipairs(meta.frames) do
    local file = assert(io.open(asset_dir .. "/" .. name, "rb"))
    local encoded = vim.base64.encode(file:read("*a"))
    file:close()
    local id = IMAGE_ID_BASE + index
    local position = 1
    local first = true
    while position <= #encoded do
      local chunk = encoded:sub(position, position + 4095)
      position = position + 4096
      local more = position <= #encoded and 1 or 0
      local control = first and string.format("a=t,t=d,f=100,i=%d,q=2,m=%d", id, more) or ("m=" .. more)
      write_terminal(graphics_command(control, chunk))
      first = false
    end
  end
  state.transmitted = true
end

local function delete_placements()
  for index = 1, #state.frames.frames do
    write_terminal(graphics_command(string.format("a=d,d=i,i=%d,q=2", IMAGE_ID_BASE + index)))
  end
end

-- Places one frame at a terminal cell. The cursor is saved, moved, and restored so Neovim's own
-- cursor position is untouched; C=1 keeps the terminal from advancing it after the image.
local function place_frame(index, row, col)
  local control = string.format(
    "a=p,i=%d,c=%d,r=%d,C=1,z=1000,q=2",
    IMAGE_ID_BASE + index, state.options.columns, state.options.rows
  )
  write_terminal(string.format("\0277\27[%d;%dH%s\0278", row, col, graphics_command(control)))
end

-- Terminal cell above the cursor line where the ghost should appear, in 1-based terminal coordinates.
local function anchor_cell()
  local screen = vim.fn.screenpos(0, vim.fn.line("."), vim.fn.col("."))
  if screen.row == 0 then
    return nil
  end
  local row = math.max(1, screen.row - state.options.rows)
  local col = math.max(1, math.min(screen.col + state.options.column_offset, vim.o.columns - state.options.columns))
  return row, col
end

local function play_image(meta)
  if not state.transmitted then
    transmit_frames(meta)
  end
  local row, col = anchor_cell()
  if not row then
    state.playing = false
    return
  end
  local delay = state.options.frame_ms or meta.delay_ms
  local index = 0
  local timer = vim.uv.new_timer()
  timer:start(0, delay, vim.schedule_wrap(function()
    if index > 0 then
      write_terminal(graphics_command(string.format("a=d,d=i,i=%d,q=2", IMAGE_ID_BASE + index)))
    end
    index = index + 1
    if index > #meta.frames then
      timer:stop()
      timer:close()
      state.playing = false
      return
    end
    place_frame(index, row, col)
  end))
end

-- Text fallback: a ghost glyph in a floating window that rises a row and fades from the
-- editor foreground purple into the background.
local GLYPH = "󰊠"
local TEXT_FRAMES = 6

local function play_text()
  local total = TEXT_FRAMES
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { GLYPH })
  local cursor_row = vim.fn.winline()
  local cursor_col = vim.fn.wincol()
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    row = math.max(0, cursor_row - 2),
    col = math.max(0, cursor_col - 2),
    width = 2,
    height = 1,
    style = "minimal",
    focusable = false,
    noautocmd = true,
    zindex = 250,
  })
  local index = 0
  local timer = vim.uv.new_timer()
  timer:start(0, 45, vim.schedule_wrap(function()
    index = index + 1
    if index > total or not vim.api.nvim_win_is_valid(win) then
      timer:stop()
      timer:close()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      state.playing = false
      return
    end
    local alpha = string.format("%02x", math.floor(255 * (1 - (index - 1) / total)))
    local color = palette.blend(palette.editorForeground .. alpha, palette.editorBackground)
    vim.api.nvim_set_hl(0, "SpookyHauntGhost", { fg = color, bg = "NONE" })
    vim.wo[win].winhighlight = "Normal:SpookyHauntGhost,NormalFloat:SpookyHauntGhost"
    vim.api.nvim_win_set_config(win, {
      relative = "win",
      row = math.max(0, cursor_row - 1 - math.floor(index / 3)),
      col = math.max(0, cursor_col - 2),
    })
  end))
end

function M.haunt()
  if state.playing then
    return
  end
  state.playing = true
  local meta = load_frames()
  if meta and kitty_supported() then
    play_image(meta)
  else
    play_text()
  end
end

local function on_keystroke()
  state.keystrokes = state.keystrokes + 1
  if state.keystrokes >= state.options.frequency then
    state.keystrokes = 0
    M.haunt()
  end
end

function M.setup(options)
  state.options = vim.tbl_deep_extend("force", defaults, options or {})
  if state.augroup then
    vim.api.nvim_del_augroup_by_id(state.augroup)
  end
  state.augroup = vim.api.nvim_create_augroup("SpookyScaryHaunt", { clear = true })
  vim.api.nvim_create_autocmd("InsertCharPre", { group = state.augroup, callback = on_keystroke })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = state.augroup,
    callback = function()
      if state.transmitted then
        delete_placements()
      end
    end,
  })
  vim.api.nvim_create_user_command("SpookyHaunt", M.haunt, { desc = "Summon the ghost now" })
end

function M.disable()
  if state.augroup then
    vim.api.nvim_del_augroup_by_id(state.augroup)
    state.augroup = nil
  end
  pcall(vim.api.nvim_del_user_command, "SpookyHaunt")
end

return M
