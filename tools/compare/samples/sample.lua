-- Line comment
--[[ Block
comment ]]
local M = {}
local MAX_GHOSTS = 13
local pi = 3.14159

--- Doc comment for a function.
---@param name string
function M.new(name, weight)
  local self = setmetatable({}, { __index = M })
  self.name = name or "pumpkin"
  self.weight = weight or 4.5
  return self
end

function M:label()
  return string.format("%s (%skg)", self.name, self.weight)
end

local function spook(target, times)
  local sounds = { "boo", 'woo', [[long string]] }
  local total = 0
  while times > 0 do
    total = total + #sounds * 2 + times % 3
    times = times - 1
  end
  for index, sound in ipairs(sounds) do
    if index == 1 and target ~= nil then
      target:scare(sound)
    elseif not sound then
      goto continue
    end
    ::continue::
  end
  repeat total = total - 1 until total <= 0
  return total >= 10 and true or false
end

M.haunted = { house = true, ghosts = MAX_GHOSTS, ["string key"] = nil }
M.spook = spook
return M
