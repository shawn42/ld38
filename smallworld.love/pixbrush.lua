local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type
local C = Pixtypes.Color

local Styles = {
  squareSpray = function(pixgrid,x,y,brush)
    for i=1,brush.rate do
      local x = x + love.math.random(-brush.size, brush.size)
      local y = y + love.math.random(-brush.size, brush.size)
      local p = pixgrid:get(x,y)
      if p and p.type == T.Off then
        pixgrid:set(x, y, brush.color[1], brush.color[2], brush.color[3], brush.type, shallowclone(brush.data))
      end
    end
  end,

  squareSolid = function(pixgrid,x,y,brush)
    local s = brush.size
    local base = - math.floor(s/2)
    for y2=base, base+s do
      for x2=base, base+s do
        pixgrid:set(x+x2, y+y2, brush.color[1], brush.color[2], brush.color[3], brush.type, shallowclone(brush.data))
      end
    end
  end,

  pixel = function(pixgrid,x,y,brush,count)
    -- count is the number of ticks this paint event has been carrying on.
    -- count == 1 the first time through.
    if count == 1 then -- only paint one pixel, even if the painter is held for longer
      pixgrid:set(x, y, brush.color[1], brush.color[2], brush.color[3], brush.type, shallowclone(brush.data))
    end
  end,

  eraser = function(pixgrid,x,y,brush)
    -- clear a square region brush.size on a side, centered on x,y
    local s = brush.size
    local base = - math.floor(s/2)
    for y2=base, base+s do
      for x2=base, base+s do
        pixgrid:clear(x+x2, y+y2)
      end
    end
  end,
}

local StyleNames = {}
for key in pairs(Styles) do
  table.insert(StyleNames, key)
end

local B = {
  Styles=Styles,
  StyleNames=StyleNames,
}

return B
