local Pixgrid = require 'pixgrid'
local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type
local Color = Pixtypes.Color
local Resources = require 'modules.pixels-ecs.resources'

local Estore = require 'ecs/estore'
require 'comps'

local Comp = require 'ecs/component'
Comp.define('pixgrid', {'pixgrid',{}})
-- Comp.define('pixbuf', {'buffer',{}})
Comp.define('pixlist', {'pix',{},'lastx',0,'lasty',0})
Comp.define('script', {'script',''})

local function toPixlist(buf)
  local list = {}
  for i=1,#buf do
    if buf[i].type ~= T.Off then
      buf[i].type = T.Entity
      list[#list+1] = buf[i]
    end
  end
  return list
end

local function newWorld(opts)
  local bounds = opts.bounds
  local world = {
    iterations=opts.iterations,
    bounds = bounds,
    bgcolor = {0,0,50},
  }

  local scale = opts.scale or 1
  local pixgrid = buildPixgrid(bounds.w, bounds.h, scale)

  local estore = Estore:new()
  estore:newEntity({
    {'name', {name='Pixel Grid'}},
    {'pos',{x=0,y=0}},
    {'bounds',{offx=0,offy=0, w=bounds.w, h=bounds.h}},
    {'pixgrid',{pixgrid=pixgrid}}
  })

  local snailBuf = love.filesystem.load('data/snail.lua')()
  local plist = toPixlist(snailBuf)
  estore:newEntity({
    {'name', {name='Snail'}},
    {'pos',{x=30,y=220}},
    {'bounds',{offx=0,offy=0, w=20, h=20}},
    {'pixlist', {pix=plist, lastx=-5000,lasty=-5000}},
    {'script', {script='crawl'}},
  })

  world.estore = estore
  world.input = {}

  world.resources = Resources.load()

  -- world.pixgrid = pixgrid

  return world
end

local function addSandDunes(pixgrid, freq, amp, topEdge)
  local top, y
  local c = Color.Sand
  local bar = topEdge or (pixgrid.h - amp) -- y location in the pixgrid of top edge of the wave
  for x = 0, pixgrid.w-1 do
    top = bar  + math.floor(math.sin(x/freq) * (amp/2))
    for y = top, bar + amp do
      pixgrid:set(x,y, c[1], c[2], c[3], T.Sand,{water=0,maxWater=100})
    end
  end
end

function buildPixgrid(w,h,scale)
  print(w,h,scale)
  local pixgrid = Pixgrid.Pixgrid:new({
    w = w/scale,
    h = h/scale,
    scale = scale,
  })

  addSandDunes(pixgrid, 15, 12)

  -- local snailBuf = love.filesystem.load('data/snail.lua')()
  -- pixgrid:applyBufferAt(snailBuf, 100,100)

  return pixgrid
end

return newWorld
