local Stats = require 'stats'

local function drawWorld (world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))
  love.graphics.setColor(255,255,255)

  love.graphics.push()
  local s = world.pixgrid.scale
  love.graphics.translate(world.pixgridBounds.x, world.pixgridBounds.y)
  love.graphics.scale(s,s)
  love.graphics.setPointSize(s)
  love.graphics.points(world.pixgrid.buf)
  love.graphics.pop()

  if world.drawStats then
    Stats.drawFPSChart(2,2)
    Stats.drawUpdateTimesChart(2,30)
  end
end

return drawWorld
