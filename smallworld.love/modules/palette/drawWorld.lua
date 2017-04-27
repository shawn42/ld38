local Pixtypes = require "pixtypes"
local T = Pixtypes.Type
local C = Pixtypes.Color

local items = {
  {label="1", typeName="Sand"},
  {label="2", typeName="Leaf"},
  {label="3", typeName="Water"},
  {label="4", typeName="Stone"},
}

local bw=50
local bh=50
local spacer=4

local function drawItem(item,x,y,w,h)
  love.graphics.setColor(unpack(C[item.typeName]))
  love.graphics.rectangle("fill", x+5,y+5, w-10,h-10)

  love.graphics.setColor(0,0,0)
  love.graphics.print(item.label, x+(w/2)-5,y+(h/2)-9.5, 0, 1.5, 1.5)
  love.graphics.setColor(255,255,255)
  love.graphics.rectangle("line", x,y, w,h)
end

local function drawWorld(world)
  for i=1,#items do
    local x = (i-1)*(bw+spacer)
    local y = spacer
    drawItem(items[i], x,y,bw,bh)
  end
end
return drawWorld
