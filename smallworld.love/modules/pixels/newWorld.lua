local Pixgrid = require 'pixgrid'
local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type
local Color = Pixtypes.Color

local prepoluatePixgrid

local function newWorld(opts)
  local world = {
    iterations=opts.iterations,
    timectrl = {
      interval = 1,  -- how often (in ticks, not time) to actually perform the update
      tickcounter = 0,
      stepwise = false,
      stepped = false,
    },
    bounds = opts.bounds,
    bgcolor = {0,0,0},
    painter = {
      on = false,
      x = 0,
      y = 0,
      type = T.Sand,
      color = Color.Sand,
      brushSize = 10,
    },
    eraser = {
      on = false,
      x = 0,
      y = 0,
      eraserSize = 10,
    },
    drawStats = not (opts.drawStats == false),
  }

  local scale = opts.scale or 1
  world.pixgrid = Pixgrid({
    w=world.bounds.w/scale,
    h=world.bounds.h/scale,
    scale=scale,
  })

  if opts.pixeldata then
    world.pixgrid:setBuffer(opts.pixeldata)
  else
    prepoluatePixgrid(world.pixgrid)
  end

  local snailBuf = love.filesystem.load('data/snail.lua')()
  world.pixgrid:applyBufferAt(snailBuf, 100,100)


  return world
end

local function addSandDunes(pixgrid, freq, amp, topEdge)
  local top, y
  local c = Color.Sand
  local bar = topEdge or (pixgrid.h - amp) -- y location in the pixgrid of top edge of the wave
  for x = 0, pixgrid.w-1 do
    top = bar  + math.floor(math.sin(x/freq) * (amp/2))
    for y = top, bar + amp do
      pixgrid:set(x,y, c[1], c[2], c[3], T.Sand)
    end
  end
end

function prepoluatePixgrid(pixgrid)
  addSandDunes(pixgrid, 15, 12)
end

return newWorld
