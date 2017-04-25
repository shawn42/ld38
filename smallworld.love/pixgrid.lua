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

local Changer = LCS.class({name = 'Changer'})

function Changer:init()
  self:reset()
end

function Changer:reset()
  -- self.sets = {}
  self.clears = {}
  self.moves = {}
end

function Changer:move(src, dest)
  table.insert(self.moves, {src, dest})
  -- table.insert(self.moves, {src, dest[1],dest[2], src[3],src[4],src[5], src.type})
end

function Changer:clear(src)
  table.insert(self.clears, src)
end

function Changer:apply(pixgrid)
  for i=1,#self.clears do
    pixgrid:clear(self.clears[i][1], self.clears[i][2])
  end

  -- for i=1,#sets do
  --   pixgrid:set(unpack(v))
  -- end

  local did = {}
  local w = pixgrid.w
  for i=1,#self.moves do
    src = self.moves[i][1]
    dest = self.moves[i][2]

    idx = 1 + dest[1] + (dest[2]*w)
    if not did[idx] then
      -- pixgrid:set(unpack(dest))
      pixgrid:set(dest[1],dest[2], src[3],src[4],src[5], src.type)
      pixgrid:clear(src[1],src[2])
      did[idx] = true
    end
  end
end

Pixgrid.Changer = Changer
Pixgrid.Types = T

return Pixgrid
