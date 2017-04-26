local Stats = require 'stats'

local function drawWorld (world)
  love.graphics.setColor(255,255,255)
  love.graphics.push()
  local s = world.pixgrid.scale
  love.graphics.scale(s,s)
  love.graphics.setPointSize(s)
  love.graphics.points(world.pixgrid.buf)
  love.graphics.pop()
end

return drawWorld
