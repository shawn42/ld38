local LCS = require 'vendor/LCS'

local T = {
  Off = 0,
  Leaf = 1,
}

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
      pixel.type = T.Off
      table.insert(self.buf, pixel)
    end
  end
end

function Pixgrid:set(x,y,r,g,b,type)
  -- local pix = self.buf[1 + (y*self.w + x)]
  local i = 1+((y * self.w) + x)
  local pix = self.buf[i]
  pix[3] = r
  pix[4] = g
  pix[5] = b
  pix.type = type
end

function Pixgrid:clear(x,y)
  self:set(x,y, 0,0,0, T.Off)
end

function Pixgrid:get(x,y)
  -- 0,0 -> 1
  -- 1,0 -> 2   -- x+1
  -- 5,1 -> -- 85 == ((80 * 1) + 5) + 1
  return self.buf[1+((y * self.w) + x)]
end

Pixgrid.Types = T

return Pixgrid
