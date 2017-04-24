local LCS = require 'vendor/LCS'

local Pixgrid = LCS.class({name = 'Pixgrid'})

function Pixgrid:init(opts)
  self.w = opts.w
  self.h = opts.h
  self.buf = {}
  self.scale = opts.scale
  self.activePixels = {}
  for r=0,self.h-1 do
    for c=0,self.w-1 do
      local pixel = {c,r, 0,0,0}
      pixel.type = 0 -- Pixtypes.Types.Off
      table.insert(self.buf, pixel)
    end
  end
end

function Pixgrid:set(x,y,r,g,b,type)
  local pix = self.buf[1 + ((y * self.w) + x)]
  if pix then
    pix[3] = r
    pix[4] = g
    pix[5] = b
    pix.type = type
  end
end

function Pixgrid:setc(x,y,color,type)
  local pix = self.buf[1 + ((y * self.w) + x)]
  if pix then
    pix[3] = color[1]
    pix[4] = color[2]
    pix[5] = color[3]
    pix.type = type
  end
end

function Pixgrid:clear(x,y)
  self:set(x,y, 0,0,0, 0) -- Pixtypes.Types.Off
end

function Pixgrid:get(x,y)
  -- 0,0 -> 1
  -- 1,0 -> 2   -- x+1
  -- 5,1 -> -- 85 == ((80 * 1) + 5) + 1
  return self.buf[1+((y * self.w) + x)]
end

Pixgrid.Types = T

return Pixgrid
