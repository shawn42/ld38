local Pixtypes = require "pixtypes"
local T = Pixtypes.Type
local C = Pixtypes.Color


-- button layout params
local bw=50
local bh=50
local spacer=4

local function drawItem(item,x,y,w,h,selected)
  local color = item.color or {255,255,255}
  love.graphics.setColor(color)
  love.graphics.rectangle("fill", x+5,y+5, w-10,h-10)

  love.graphics.setColor(0,0,0)
  love.graphics.print(item.label, x+(w/2)-5,y+(h/2)-9.5, 0, 1.5, 1.5)
  love.graphics.setColor(255,255,255)
  if selected then
    love.graphics.rectangle("line", x,y, w,h)
  end
end

local function drawWorld(world)
  for i=1,#world.items do
    local x = (i-1)*(bw+spacer)
    local y = spacer
    local selected = (world.brushName == world.items[i].brushName)
    drawItem(world.items[i], x,y,bw,bh, selected)
  end
end
return drawWorld
