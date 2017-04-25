local Stats = require 'stats'

local function drawWorld (world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))
  love.graphics.setColor(255,255,255)

  love.graphics.push()
  local s = world.pixgrid.scale
  love.graphics.setPointSize(s)
  love.graphics.scale(s,s)
  love.graphics.points(world.pixgrid.buf)
  love.graphics.pop()

  -- love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  -- love.graphics.print("Num times: "..tostring(#Stats.updateTimes), 10, 20)
  love.graphics.setPointSize(1)
  Stats.drawFPSChart(2,2)
  Stats.drawUpdateTimesChart(2,30)
end

return drawWorld
