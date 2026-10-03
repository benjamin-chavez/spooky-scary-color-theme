-- A ghost rises out of the cursor line every N keystrokes, like the Power Mode setup in the
-- README: a small purple silhouette, about one cell tall, gone in a quarter second. In a
-- terminal that speaks the Kitty graphics protocol (Ghostty, Kitty, WezTerm) it plays the
-- README's ghost GIF frames; elsewhere it animates a glyph that rises and fades.
local M = {}

local palette = require("spooky-scary.palette")

local defaults = {
  enabled = true, -- the persisted choice from :SpookyHauntToggle overrides this
  state_file = vim.fn.stdpath("data") .. "/spooky-scary/haunt-enabled",
  frequency = 20,
  frame_ms = nil, -- defaults to the GIF's own timing from assets/ghost/frames.lua
  columns = 6, -- width of the image ghost in terminal cells; 6 by 2 keeps the frames' aspect
  rows = 2, -- height of the image ghost in terminal cells
  column_offset = -3, -- cells left of the cursor where the ghost box starts, centering it on the cursor
  graphics = "auto", -- "auto", "kitty" or "text"
}

local state = {
  options = nil,
  enabled = false,
  keystrokes = 0,
  playing = false,
  frames = nil,
  transmitted = false,
  augroup = nil,
  commands_defined = false,
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

-- Image ids are arbitrary but must not collide with other plugins. Each color set gets a
-- block of 100 ids above 7700.
local IMAGE_ID_BASE = 7700

local function image_id(set_index, frame_index)
  return IMAGE_ID_BASE + set_index * 100 + frame_index
end

-- Power Mode's mask mode fills the ghost with the color of the token under the cursor. This
-- resolves that color the way the highlighter does: the last capture with a foreground wins.
local function cursor_token_color()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  col = math.max(0, col - 1)
  local ok, info = pcall(vim.inspect_pos, 0, row - 1, col)
  local color = nil
  if ok then
    for _, item in ipairs(info.treesitter or {}) do
      local hl = vim.api.nvim_get_hl(0, { name = item.hl_group_link or item.hl_group, link = false })
      if hl.fg then color = hl.fg end
    end
    if not color then
      for _, item in ipairs(info.syntax or {}) do
        local hl = vim.api.nvim_get_hl(0, { name = item.hl_group_link or item.hl_group, link = false })
        if hl.fg then color = hl.fg end
      end
    end
  end
  color = color or vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg
  return color and string.format("#%06x", color) or palette.editorForeground
end

local function rgb(hex)
  return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

-- Index of the pre-tinted frame set nearest to a color.
local function nearest_set(meta, hex)
  local r, g, b = rgb(hex)
  local best, best_distance = 1, math.huge
  for index, candidate in ipairs(meta.colors) do
    local cr, cg, cb = rgb(candidate)
    local distance = (r - cr) ^ 2 + (g - cg) ^ 2 + (b - cb) ^ 2
    if distance < best_distance then
      best, best_distance = index, distance
    end
  end
  return best
end

-- Sends one color set's frames as PNG data in 4096-byte chunks, once. q=2 suppresses terminal
-- replies, which would otherwise land in Neovim's input.
local transmitted_sets = {}
local function transmit_frames(meta, set_index)
  if transmitted_sets[set_index] then
    return
  end
  local directory = asset_dir .. "/" .. meta.colors[set_index]:sub(2)
  for index, name in ipairs(meta.frames) do
    local file = assert(io.open(directory .. "/" .. name, "rb"))
    local encoded = vim.base64.encode(file:read("*a"))
    file:close()
    local id = image_id(set_index, index)
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
  transmitted_sets[set_index] = true
  state.transmitted = true
end

local function delete_placements()
  for set_index in pairs(transmitted_sets) do
    for index = 1, #state.frames.frames do
      write_terminal(graphics_command(string.format("a=d,d=i,i=%d,q=2", image_id(set_index, index))))
    end
  end
end

-- Places one frame at a terminal cell. The cursor is saved, moved, and restored so Neovim's own
-- cursor position is untouched; C=1 keeps the terminal from advancing it after the image.
local function place_frame(set_index, index, row, col)
  local control = string.format(
    "a=p,i=%d,c=%d,r=%d,C=1,z=1000,q=2",
    image_id(set_index, index), state.options.columns, state.options.rows
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

local function play_image(meta, color)
  local set_index = nearest_set(meta, color)
  transmit_frames(meta, set_index)
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
      write_terminal(graphics_command(string.format("a=d,d=i,i=%d,q=2", image_id(set_index, index))))
    end
    index = index + 1
    if index > #meta.frames then
      timer:stop()
      timer:close()
      state.playing = false
      return
    end
    place_frame(set_index, index, row, col)
  end))
end

-- Text fallback: a ghost glyph in a floating window that rises a row and fades from the
-- cursor token's color into the background.
local GLYPH = "󰊠"
local TEXT_FRAMES = 6

local function play_text(color)
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
    local faded = palette.blend(color .. alpha, palette.editorBackground)
    vim.api.nvim_set_hl(0, "SpookyHauntGhost", { fg = faded, bg = "NONE" })
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
  local color = cursor_token_color()
  local meta = load_frames()
  if meta and kitty_supported() then
    play_image(meta, color)
  else
    play_text(color)
  end
end

local function on_keystroke()
  state.keystrokes = state.keystrokes + 1
  if state.keystrokes >= state.options.frequency then
    state.keystrokes = 0
    M.haunt()
  end
end

-- The persisted choice is a one-line file holding "on" or "off"; absence means "use the option".
local function read_persisted()
  local file = io.open(state.options.state_file, "r")
  if not file then
    return nil
  end
  local word = (file:read("*l") or ""):match("^%s*(%a+)")
  file:close()
  if word == "on" then return true end
  if word == "off" then return false end
  return nil
end

local function write_persisted(enabled)
  vim.fn.mkdir(vim.fs.dirname(state.options.state_file), "p")
  local file = io.open(state.options.state_file, "w")
  if file then
    file:write(enabled and "on\n" or "off\n")
    file:close()
  end
end

local function register_autocmds()
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
end

local function clear_autocmds()
  if state.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, state.augroup)
    state.augroup = nil
  end
end

local function apply(enabled, persist)
  state.enabled = enabled
  clear_autocmds()
  if enabled then
    register_autocmds()
  end
  if persist then
    write_persisted(enabled)
  end
end

function M.enable()
  apply(true, true)
  vim.notify("Spooky ghost: on", vim.log.levels.INFO)
end

function M.disable()
  apply(false, true)
  vim.notify("Spooky ghost: off", vim.log.levels.INFO)
end

function M.toggle()
  if state.enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.is_enabled()
  return state.enabled
end

local function define_commands()
  if state.commands_defined then
    return
  end
  state.commands_defined = true
  vim.api.nvim_create_user_command("SpookyHaunt", M.haunt, { desc = "Summon the ghost now" })
  vim.api.nvim_create_user_command("SpookyHauntToggle", M.toggle, { desc = "Toggle the ghost and remember the choice" })
  vim.api.nvim_create_user_command("SpookyHauntEnable", M.enable, { desc = "Turn the ghost on and remember the choice" })
  vim.api.nvim_create_user_command("SpookyHauntDisable", M.disable, { desc = "Turn the ghost off and remember the choice" })
end

-- Called by the colorscheme on load with no options, and again by user config with options.
-- A persisted on/off choice always wins over the `enabled` option.
function M.setup(options)
  state.options = vim.tbl_deep_extend("force", defaults, options or {})
  define_commands()
  local persisted = read_persisted()
  local enabled = state.options.enabled
  if persisted ~= nil then
    enabled = persisted
  end
  apply(enabled, false)
end

return M
