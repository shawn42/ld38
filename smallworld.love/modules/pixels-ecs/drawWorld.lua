local Helpers = require 'modules.pixels-ecs.helpers'
local Stats = require 'stats'


local getPixgrid = Helpers.getPixgrid
local function drawWorld(world)
  local pixgrid = getPixgrid(world.estore)
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
