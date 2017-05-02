local Stats = require 'stats'

local function drawWorld(world)

  local pixgrid
  world.estore:seekEntity(hasComps('pixgrid'), function(e)
    pixgrid = e.pixgrid.pixgrid
  end)

  if pixgrid then
    love.graphics.setColor(255,255,255)
    love.graphics.push()
    local s = pixgrid.scale
    love.graphics.scale(s,s)
    love.graphics.setPointSize(s)
    love.graphics.points(pixgrid.buf)
    love.graphics.pop()
  end
end

return drawWorld
