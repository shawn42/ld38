local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type

local LCS = require 'vendor/LCS'
local M = {}
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

function Pixgrid:setBuffer(newBuf)
  self.buf = newBuf
end

function Pixgrid:set(x,y,r,g,b,type,data)
  local pix = self.buf[1 + ((y * self.w) + x)]
  if pix then
    pix[3] = r
    pix[4] = g
    pix[5] = b
    pix.type = type
    pix.data = data
  end
end

function Pixgrid:clear(x,y)
  self:set(x,y, 0,0,0, T.Off ,nil)
end

function Pixgrid:get(x,y)
  -- 0,0 -> 1
  -- 1,0 -> 2   -- x+1
  -- 5,1 -> -- 85 == ((80 * 1) + 5) + 1
  return self.buf[1+((y * self.w) + x)]
end
function Pixgrid:fillNeighbors(p,nei)
  -- 1+((y * self.w) + x)
  local px = p[1]
  local py = p[2]
  local buf = self.buf
  local w = self.w
  nei[1] = buf[    ((py-1) * w) + px] or 0
  nei[2] = buf[1 + ((py-1) * w) + px] or 0
  nei[3] = buf[2 + ((py-1) * w) + px] or 0
  nei[4] = buf[    (py * w) + px] or 0
  -- nei[5] = buf[1 + (py * w) + px] or 0
  nei[6] = buf[2 + (py * w) + px] or 0
  nei[7] = buf[    ((py+1) * w) + px] or 0
  nei[8] = buf[1 + ((py+1) * w) + px] or 0
  nei[9] = buf[2 + ((py+1) * w) + px] or 0
end

function Pixgrid:applyBufferAt(buf, xOffset, yOffset)
  for i=1,#buf do
    local p = buf[i]
    local x = p[1] + xOffset
    local y = p[2] + yOffset

    local t = p.type
    if t ~= T.Off then t = T.Entity end -- quick fix, avoids the poor snail's shell from crumbling
    self:set(x,y, p[3],p[4],p[5],t,p.data)
  end
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
end

function Changer:overwrite(src, dest)
  table.insert(self.clears, dest)
  table.insert(self.moves, {src, dest})
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

    -- idx = 1 + dest[1] + (dest[2]*w)
    -- if not did[idx] then
    --   pixgrid:set(dest[1],dest[2], src[3],src[4],src[5], src.type, src.data)
    --   pixgrid:clear(src[1],src[2])
    --   did[idx] = true
    -- end

    idxd = 1 + dest[1] + (dest[2]*w)
    idxs = 1 + src[1] + (src[2]*w)
    if not did[idxd] and not did[idxs] then
      local dr = dest[3]
      local dg = dest[4]
      local db = dest[5]
      local dtype = dest.type
      local ddata = dest.data
      pixgrid:set(dest[1],dest[2], src[3],src[4],src[5], src.type, src.data)
      pixgrid:set(src[1],src[2], dr,dg,db, dtype, ddata)
      did[idxd] = true
      did[idxs] = true
    end
  end
end

M.Changer = Changer
-- M.Types = T
M.Pixgrid = Pixgrid

return M
